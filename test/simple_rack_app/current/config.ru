# Define a simple "app"
app = proc do |env|
  [ 200, { "Content-Type" => "text/html" }, ["hello, world"] ]
end

# Run the app
run app
