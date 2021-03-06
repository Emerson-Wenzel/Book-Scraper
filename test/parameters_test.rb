#!/usr/bin/ruby

# require the parameters class
require_relative '../connection/parameters.rb'

# ------------ Tests ---------------

# Test 1: Ensure a valid Parameter object can be created or an error is thrown if one cannot
begin
    a=Parameters.new(1234567,7654321,1234567,7654321,Parameters::TERM)
    puts "Passed"
rescue
    puts "Failed"
end
begin
    a=Parameters.new(1234567,7654321,1234567,7654321,Parameters::DEPT)
    puts "Passed"
rescue
    puts "Failed"
end
begin
    a=Parameters.new(1234567,7654321,1234567,7654321,Parameters::COURSE)
    puts "Passed"
rescue
    puts "Failed"
end
begin
    a=Parameters.new(1234567,7654321,1234567,nil,Parameters::TERM)
    puts "Passed"
rescue
    puts "Failed"
end
begin
    a=Parameters.new(1234567,7654321,1234567,nil,Parameters::DEPT)
    puts "Passed"
rescue
    puts "Failed"
end
begin
    a=Parameters.new(1234567,7654321,1234567,nil,Parameters::COURSE)
    puts "Passed"
rescue
    puts "Failed"
end
begin
    a=Parameters.new(1234567,7654321,nil,nil,Parameters::TERM)
    puts "Passed"
rescue
    puts "Failed"
end
begin
    a=Parameters.new(1234567,7654321,nil,nil,Parameters::DEPT)
    puts "Passed"
rescue
    puts "Failed"
end
begin
    a=Parameters.new(1234567,7654321,nil,nil,Parameters::COURSE)
    puts "Failed"
rescue
    puts "Passed"
end
begin
    a=Parameters.new(1234567,nil,nil,nil,Parameters::TERM)
    puts "Passed"
rescue
    puts "Failed"
end
begin
    a=Parameters.new(1234567,nil,nil,nil,Parameters::DEPT)
    puts "Failed"
rescue
    puts "Passed"
end
begin
    a=Parameters.new(1234567,nil,nil,nil,Parameters::COURSE)
    puts "Failed"
rescue
    puts "Passed"
end
begin
    a=Parameters.new(nil,nil,nil,nil,Parameters::TERM)
    puts "Failed"
rescue
    puts "Passed"
end

# Test 2: Pass in non Parameter dropdown options and ensure an object fails to be created
begin
    a=Parameters.new(1234567,7654321,1234567,7654321,nil)
    puts "Passed"
rescue
    puts "Failed"
end
begin
    a=Parameters.new(1234567,7654321,1234567,7654321,0)
    puts "Failed"
rescue
    puts "Passed"
end
begin
    a=Parameters.new(1234567,7654321,1234567,7654321,"hello")
    puts "Failed"
rescue
    puts "Passed"
end
begin
    a=Parameters.new(1234567,7654321,1234567,7654321,"dept")
    puts "Passed"
rescue
    puts "Failed"
end

# Test 3: Ensure the to_s function works properly
term=1
dept=2
course=3
section=4
dropdown=Parameters::TERM
expected_rep="&termId=#{term}&deptId=#{dept}&courseId=#{course}&sectionId=#{section}&dropdown=#{dropdown}"
a=Parameters.new(term,dept,course,section,dropdown)
actual_rep=a.to_s
if actual_rep.eql? expected_rep
    puts "Passed"
else
    puts "Failed"
end
expected_rep="&termId=#{term}&deptId=#{dept}&courseId=#{course}&dropdown=#{dropdown}"
a=Parameters.new(term,dept,course,nil,dropdown)
actual_rep=a.to_s
if actual_rep.eql? expected_rep
    puts "Passed"
else
    puts "Failed"
end
expected_rep="&termId=#{term}&deptId=#{dept}&dropdown=#{dropdown}"
a=Parameters.new(term,dept,nil,nil,dropdown)
actual_rep=a.to_s
if actual_rep.eql? expected_rep
    puts "Passed"
else
    puts "Failed"
end
expected_rep="&termId=#{term}&dropdown=#{dropdown}"
a=Parameters.new(term,nil,nil,nil,dropdown)
actual_rep=a.to_s
if actual_rep.eql? expected_rep
    puts "Passed"
else
    puts "Failed"
end
