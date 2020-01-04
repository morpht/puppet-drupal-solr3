# This is an autogenerated function, ported from the original legacy version.
# It /should work/ as is, but will not have all the benefits of the modern
# function API. You should see the function docs to learn how to add function
# signatures for type safety and to document this function using puppet-strings.
#
# https://puppet.com/docs/puppet/latest/custom_functions_ruby.html
#
# ---- original file header ----
require 'digest/md5'
# internal function to generate random password
def _my_mkpass()
  mymkpass = ''
  9.to_i.times{ mymkpass  << (65 + rand(25)).chr }
  return mymkpass
end
#
# ---- original file header ----
#
# @summary
#   Summarise what the function does here
#
Puppet::Functions.create_function(:'generate_usrpass') do
  # @param args
  #   The original array of arguments. Port this to individually managed params
  #   to get the full benefit of the modern function API.
  #
  # @return [Data type]
  #   Describe what the function returns here
  #
  dispatch :default_impl do
    # Call the method named 'default_impl' when this is matched
    # Port this to match individual params for better type safety
    repeated_param 'Any', :args
  end


  def default_impl(*args)
    
  corecnt = args[0]
  usrarr = Array.new(corecnt.to_i)

  # the first user is admin, excluding from the loop
  randpass = _my_mkpass()
  usrarr[0] = Hash.new
  usrarr[0]['user'] = 'admin'
  usrarr[0]['pass'] = randpass
  usrarr[0]['hash'] = Digest::MD5.hexdigest(randpass)

  for i in 1..corecnt.to_i do
    usr = 'core'+i.to_s
    randpass = _my_mkpass()
    usrarr[i] = Hash.new
    usrarr[i]["user"] = usr
    usrarr[i]["pass"] = randpass
    usrarr[i]["hash"] = Digest::MD5.hexdigest(randpass)

    # a little hack for the admin user - adding all roles:
    usrarr[0]['hash'] << ',' << usr
  end
  return usrarr

  end
end