# Increase key space for post request.
# Warning, this is dangerous. See http://stackoverflow.com/questions/12243694/getting-error-exceeded-available-parameter-key-space
Rack::Utils.key_space_limit = 262144
