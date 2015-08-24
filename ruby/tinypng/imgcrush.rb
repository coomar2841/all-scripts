require "net/https"
require "uri"

# API Key
# Kumar
key = "Paste your API key here"

report = []

# Directory glob pattern, you should run the script from the root project directory and 
# provide a relative path for the glob
files = Dir.glob('app/src/main/res/**/*.png')
files_count = files.size
puts 'Found ' + files_count.to_s + ' files'

count = 0
Dir.glob('app/src/main/res/**/*.png') do |file|
	
	# next

	puts (files_count - count).to_s + ' more to go...'
	count = count + 1
	file_details = Hash.new
	file_details[:file] = file
	file_details[:size_before] = File.size(file)

	input = file
	output = file

	uri = URI.parse("https://api.tinypng.com/shrink")

	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true

	# Uncomment below if you have trouble validating our SSL certificate.
	# Download cacert.pem from: http://curl.haxx.se/ca/cacert.pem
	# http.ca_file = File.join(File.dirname(__FILE__), "cacert.pem")

	request = Net::HTTP::Post.new(uri.request_uri)
	request.basic_auth("api", key)

	response = http.request(request, File.binread(input))
    
	if response.code == "201"
	  # Compression was successful, retrieve output from Location header.
	  File.binwrite(output, http.get(response["location"]).body)
	  file_details[:size_after] = File.size(file)

	  report.push file_details
	else
	  # Something went wrong! You can parse the JSON body for details.
	  puts "Compression failed"
	end
end
puts 'All files crushed'
puts 'Generating report...'



# Generate Report - For now, all your files have been crushed
total_savings = 0
timestamp = Time.now.strftime("%b %-d (%A), %Y %H:%M:%S")
report_file = File.new('tinypng-crush-report.html', 'w')
report_file.puts('<html>')
report_file.puts('<body>')
report_file.puts('<h3>' + 'TinyPng Crush Report - ' + timestamp + '</h3>')
report_file.puts('<hr/>')
report_file.puts('<style type="text/css">')
report_file.puts('.footer{font-weight: bold;}')
report_file.puts('table tbody th td{border: 1px solid black;}')
report_file.puts('border-collapse: collapse;')
report_file.puts('</style>')
report_file.puts('<table>')
report_file.puts('<tr><th>File</th><th>Before</th><th>After</th><th>Savings</th></tr>')
report.each do |record|
	report_file.puts('<tr>')
	report_file.puts('<td>' + record[:file] + '</td>')
	report_file.puts('<td>' + record[:size_before].to_s + '</td>')
	report_file.puts('<td>' + record[:size_after].to_s + '</td>')
	savings = record[:size_before] - record[:size_after]
	total_savings = total_savings + savings
	report_file.puts('<td>' + savings.to_s + '</td>')	
	report_file.puts('</tr>')
end
report_file.puts('</table>')
report_file.puts('<br/><div class="footer">Total files Processed: ' + files_count.to_s + '</div>')
report_file.puts('<div class="footer">Total savings in bytes: ' + total_savings.to_s + '</div>')
report_file.puts('</body>')
report_file.puts('</html>')
report_file.close