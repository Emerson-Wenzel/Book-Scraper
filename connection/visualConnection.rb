#!/usr/bin/ruby

# Require classes to use the Capybara functionality.
require 'rubygems'
require 'capybara'
require 'capybara/dsl'

class VisualConnection < Connection
    
    # Set up defaults to use when opening a connection
    def initialize(parameters = nil)
        super
        Capybara.default_driver = :selenium
        Capybara.app_host = BASE_WEBPAGE
        Capybara.run_server = false
    end
    
    # Open a connection to the B&N site and grab the body 
    def open_connection
        
        @session = Capybara::Session.new(:selenium)
        @session.visit("/#{VISUAL_WEBPAGE_FILE}?#{COMMON_PARAMETERS}")
        @page = @session.find(:xpath, '//body')
        check_connection
        
    end
    
    # Terminate the connection to the B&N site
    def close_connection
        
        @session.driver.quit
        super
        
    end
    
    # Fill out the form and press submit button
    # term instance_of? Term, dept instance_of? Dept, course instance_of? Course, section instance_of? Section
    def enterCourseInformation(sections)
 
        if @page.nil?
            @@logger.append "Unable to parse nil session. Scraping will terminate unless rescued."
            raise "Unable to work on a nil connection."
        end
        
        if @parameters.nil? 
            @@logger.append "Unable to scrape a book from a nil course. Provide VisualConnection with a valid Parameters list." 
            raise "Unable to scrape a book from a nil course. Provide VisualConnection with a valid Parameters list." 
        end
        
        rows = @session.all('.bookRowContainer')
        if rows.nil? # either page loaded wrong or the schema has changed
            @@logger.append "Check your connection and ensure the HTML schema has not changed. Then, try again. Scraping will terminate unless rescued."
            raise "Check your connection and ensure the HTML schema has not changed. Then, try again."
        end
        
        # 3 parallel arrays simplify the amount of repeated code.
        headerElements = ['.termHeader', '.deptSelectInput', '.courseSelectInput', '.sectionSelectInput']
        childElements = ['.termHeader li', '.deptColumn li', '.courseColumn li', '.sectionColumn li']
        paramValues = [parameters.termId, parameters.deptId, parameters.courseId]
        
        # Grab a reference to the 'additional rows' button
        addRow = @session.find('.addMoreRows')
        
        # Scrape all sections together, since we are splitting the books based on dept and course, not section
        rowNum = 0
        sections.each do |currSection|
            # Click on the header element
            4.times do |currElement|
                rows[rowNum].find(headerElements[currElement]).click 
                foundElement = false
                if currElement === 0 # Term requires special handling
                    rows[rowNum].all(childElements[currElement]).each do |element|
                        if element['data-optionvalue'].eql? paramValues[currElement]
                            element.click
                            foundElement = true
                            break
                        end
                    end
                elsif currElement === 3 # section requires special handling
                    rows[rowNum].all(childElements[currElement]).each do |element|
                        if element.text.eql? currSection.category.name
                            element.click
                            foundElement = true
                            break
                        end 
                    end
                else # Select dept or course depending on the current element value
                    rows[rowNum].all(childElements[currElement]).each do |element|
                        if element.text.eql? paramValues[currElement]
                            element.click
                            foundElement = true
                            break
                        end 
                    end
                end
                if !foundElement
                    @@logger.append "Unable to find element #{paramValues[currElement]} on page."
                    raise "Unable to find element #{paramValues[currElement]} on page." 
                end
            end # end elements loop
            rowNum = rowNum + 1
            addRow.click # add another row
            rows = @session.all('.bookRowContainer') # update rows after adding a new one
    
        end # end section loop

    end # end selectSections

    # Submit the page 
    def submitRequest
        @page.find_by_id('findMaterialButton').click
    end
    
    # Scrape books from the B&N form submission page
    def scrapeBooks
       
		# Fix stale element exception issue where the book info is incorrectly referenced
		allBooks = nil
		begin
			allBooks = @page.all('.cm_tb_bookInfo')
		rescue
			sleep 1
			retry
		end

        # Array of book entities
        books = Array.new
        allBooks.each do |bookInfo|
            if !bookInfo.find_by_id('skipNavigationToThisElement').text.eql? 'COURSE MATERIALS SELECTION PENDING'
                book = Book.new
                
                #Grab title and author
                book.title = bookInfo.find('a').text
                book.author = bookInfo.find('h2 span i').text.scan(/By (.*)/)[0][0]
                
                # Grab course information
                book.course.department = parameters.deptId
                book.course.number = parameters.courseId
                
                # Scrape publisher, edition and isbn
                bookInfo.all('li').each do |info|
                    
                    # Figure out if it is an edition, publisher or isbn
                    elem = info.text.scan(/EDITION: (.*)/)
                    if elem.size != 0
                        book.edition = elem[0][0]
                        next
                    end
                    elem = info.text.scan(/PUBLISHER: (.*)/)
                    if elem.size != 0
                        book.publisher = elem[0][0]
                        next
                    end
                    elem = info.text.scan(/ISBN: (.*)/)
                    if elem.size != 0
                        book.isbn = elem[0][0]
                        next
                    end
                    
                    @@logger.append "Text: #{info.text} does not match as an Edition, Publisher or ISBN."
                    raise "Text: #{info.text} does not match as an Edition, Publisher or ISBN."
                    
                end
                
                # Scrape image link
                @page.all('.cm_tb_image a img').each do |image|
                    book.image = image['src'] if image['title'].eql? book.title 
                end
                books << book if !book.edition.eql? 'N/A' # Filter out non-book items such as binders, folders, etc.
            end
        end
        
        if books.size === 0
            puts "No Book found. Materials pending."
        end
        
        return books
        
    end

end
