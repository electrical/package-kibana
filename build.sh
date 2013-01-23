#!/bin/sh

basedir=`pwd`

# centos or debian
os=$1
# your name
maintainer=$2

echo "Building Kibana package for $os with maintainer '$maintainer'"

if [[ $os == "centos" ]]; then

  # Create required directories
  mkdir -p $basedir/build_root_centos/usr/local
  mkdir -p $basedir/build_root_centos/etc/rc.d/init.d
  mkdir -p $basedir/build_root_centos/etc/sysconfig

  # Fetch the latest code, build the libraries and
  # remove files we don't need
  cd $basedir/build_root_centos/usr/local
  git clone https://github.com/rashidkpc/Kibana.git ./kibana
  cd kibana
  bundle install --deployment
  rm -rf .git .travis.yml .gitignore

  # Copy the init file and make it executable
  cd $basedir/build_root_centos/etc/rc.d/init.d
  cp $basedir/kibana.init.centos ./kibana
  chmod a+rx kibana

  # Copy the default file
  cd $basedir/build_root_centos/etc/sysconfig
  cp $basedir/kibana.sysconfig.centos ./kibana

  # Ensure everythign has the correct settings
  cd $basedir/build_root_centos
  find . -type d -exec chmod a+rx {} \;
  find . -type f -exec chmod a+r {} \;

  # Lets build the package
  cd $basedir
  fpm -s dir \
    -t rpm \
    -n kibana \
    -v 0.2.0 \
    --iteration '1.el6' \
    --license MIT \
    --category 'System Environment/Daemons' \
    -a 'noarch' \
    --description 'Kibana is a web interface for Logstash.' \
    --url 'http://kibana.org' \
    --vendor 'Kibana.Org' \
    --maintainer "$maintainer" \
    -d 'ruby' \
    --rpm-user 'root' \
    --rpm-group 'root' \
    -C build_root_centos .

  # Clean up the build directory
  rm -rf $basedir/build_root_centos

elif [[ $os == "debian" ]]; then

  # Create required directories
  mkdir -p $basedir/build_root_debian/usr/local
  mkdir -p $basedir/build_root_debian/etc/init.d
  mkdir -p $basedir/build_root_debian/etc/default

  # Fetch the latest code, build the libraries and
  # remove files we don't need
  cd $basedir/build_root_debian/usr/local
  git clone git://github.com/rashidkpc/Kibana.git ./kibana
  cd kibana
  bundle install --deployment
  rm -rf .git .travis.yml .gitignore

  # Copy the init file and make it executable
  cd $basedir/build_root_debian/etc/init.d
  cp $basedir/kibana.init.debian ./kibana
  chmod a+rx kibana

  # Copy the default file
  cd $basedir/build_root_debian/etc/default
  cp $basedir/kibana.default.debian ./kibana

  # Ensure everythign has the correct settings
  cd $basedir/build_root_debian
  find . -type d -exec chmod a+rx {} \;
  find . -type f -exec chmod a+r {} \;

  # Lets build the package
  cd $basedir
  fpm -s dir \
    -t deb \
    -n kibana \
    -v 0.2.0 \
    --iteration '1' \
    --license MIT \
    -a 'all' \
    --description 'Kibana is a web interface for Logstash.' \
    --url 'http://kibana.org' \
    --vendor 'Kibana.Org' \
    --maintainer "$maintainer" \
    -d 'ruby' \
    --deb-user 'root' \
    --deb-group 'root' \
    -C build_root_debian .

  # Clean up the build directory
  rm -rf $basedir/build_root_debian

fi
