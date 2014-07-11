require 'digest/md5'
# internal function to generate random password
def _my_mkpass()
  mymkpass = ''
  9.to_i.times{ mymkpass  << (65 + rand(25)).chr }
  return mymkpass
end
#
module Puppet::Parser::Functions
  newfunction(:generate_usrpass, :type => :rvalue) do |args|
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
