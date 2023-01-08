# Use zip codes and the Google Civic Information webservice to query for the representatives of a given area

require 'csv' # Includes CSV library
require 'google/apis/civicinfo_v2' # Include Google Civid Info gem
require 'erb' # Include ERB templating library

# Define a clean zipcode method
def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4] # Convert to string, pad 0's if to make a length of 5, then only grab the first 5 digits
end

# Define a legislators by zipcode method
def legislators_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw' # Use Launch School's API key
  
    begin
      legislators = civic_info.representative_info_by_address( # Makes the API call with certain parameters
        address: zip,
        levels: 'country',
        roles: ['legislatorUpperBody', 'legislatorLowerBody']
      ).officials # Return the original array of legislators
    rescue
      'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
  end

# Define a save thank you letter method
def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output') # Make a directory called output unless it already exists
  filename = "output/thanks_#{id}.html" # Create a filename
  File.open(filename, 'w') do |file| # Run open class method of File class, input the filename and write mode; for the file, encode in the contents of form_letter
    file.puts form_letter
  end
end

puts 'Event Manager Initialized!'
# puts File.exist? "event_attendees.csv" # Prints true, confirms that the file exists in the current directory

contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol # Option to convert headers to symbols, which makes the column names more uniform and easier to remember
)

template_letter = File.read('form_letter.erb') # Get template letter in file in memory
erb_template = ERB.new template_letter # Make ERB template file from template_letter object

contents.each do |row|
    id = row[0] # Give each row an ID based on the ID column
    name = row[:first_name] # Extract each name

    zipcode = clean_zipcode(row[:zipcode]) # Give each row a zip code

    legislators = legislators_by_zipcode(zipcode) # Get array of legislators

    form_letter = erb_template.result(binding) # The binding method returns a special object, which knows all about the current state of variables and methods within the given scope

    save_thank_you_letter(id,form_letter) # Make a thank you letter for each row, given ID and form_letter object

    # puts form_letter # Prints each form to the console
end