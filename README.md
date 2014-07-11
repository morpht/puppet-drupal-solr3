# puppet-drupal-solr3

Solr 3.6.2 for Drupal 7 and Ubuntu 12.04.

## Usage

```
sudo apt-get install puppet git wget
git clone https://github.com/morpht/puppet-drupal-solr3.git /tmp/puppet-drupal-solr3
sudo mv /tmp/puppet-drupal-solr3 /opt/

sudo puppet apply --modulepath=/opt/puppet-drupal-solr3 -e 'class { 'solr': search_module => 'search_api_solr', corecount => 4 }'
```

## Overview
This puppet manifest is from year 2012 published here for reference. It was part of Morpht Provision (http://morpht.com/projects/provision).

This configuration provisions a multicore Apache Solr server on your node and makes it ready for Drupal.

It sets up an HTTP authentication – each core will be protected by a different user+random password pair.

It installs openjdk-7-jre, creates an unpriviledged user for solr and runs jetty as this user.

The Solr server will be available at: http://\<your-FQDN\>:8983/solr/ (also on http://127.0.0.1:8983/solr/ - you might want to use that one it you install it on the same server as your Drupal installation).

You can choose whether you want to deploy config files for the Search API Solr search or the Apache Solr Search Integration module.

## Security Recommendation

Set up a firewall rule to protect your solr server – block port 8983 and open it only for these IP addresses you to access the solr from.

## Possible Future Enhancements

* use docker instead of this,
* Ubuntu 14.04 has Solr 3.6.2 in its repo. Use it instead of this.
* the ability to select which cores should be configured for the Search API Solr search and which ones for the Apache Solr Search Integration module,
* the ability to name cores,
* the ability to choose your port (instead of the default 8983),
* the ability to select an interface / IP address the Solr server listens on,
* the ability to avoid installing openjdk-7-jre (you are using different java).

## After Installation

The user/password information can be found in this file: /root/solr_pass.txt.

The solr installation is under /opt/solr, you can start/stop/restart it using the /etc/init.d/jetty6 script.

## Author

Marji Cermak marji@morpht.com, http://morpht.com

## Credits

This project was developed in 2012 by [Morpht](http://morpht.com/), a Drupal services company, http://morpht.com.
