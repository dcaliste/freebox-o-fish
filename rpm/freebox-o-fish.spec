# RPM spec file for (Free) Box-o-fish.
# This file is used to build Redhat Package Manager packages for
# Maep.  Such packages make it easy to install and uninstall
# the library and related files from binaries or source.
#
# RPM. To build, use the command: rpmbuild --clean -ba maep-qt.spec
#

Name: harbour-freebox-o-fish

Summary: A Freebox compagnon
Version: 0.3.1
Release: 1
License: GPLv3
Source: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Requires: sailfishsilica-qt5
Requires: mapplauncherd-booster-silica-qt5
Requires: nemo-qml-plugin-contacts-qt5
Requires: sailfish-components-contacts-qt5
BuildRequires: pkgconfig(qdeclarative5-boostable)
BuildRequires: pkgconfig(sailfishapp)

%description
Freebox-o-fish is a software to access the Freebox OS as provided
by the French ISP called Free.

%prep
rm -rf $RPM_BUILD_ROOT
%setup -q -n %{name}-%{version}

%build
rm -rf tmp
mkdir tmp
cd tmp
%qmake5 -o Makefile ../src/freebox-o-fish.pro
make %{?jobs:-j%jobs}

%install
rm -rf %{buildroot}
cd tmp
%qmake5_install

%post
if [ "$1" = 1 ] ; then
 if ! grep -qs "harbour-freebox-o-fish" /usr/share/mapplauncherd/privileges ; then
  echo "/usr/bin/harbour-freebox-o-fish,a" >> /usr/share/mapplauncherd/privileges
 fi
fi

%preun
if [ "$1" = 0 ] ; then
 sed -i "/harbour-freebox-o-fish/d" /usr/share/mapplauncherd/privileges
fi

%files
%defattr(-,root,root,-)
/usr/share/applications
/usr/share/icons
/usr/share/%{name}
/usr/bin

%changelog
* Fri Mar 21 2014 - Damien Caliste <dcaliste@free.fr> 0.3.1-1
- update phone number presentation when there is no saved contact associated to use 1.0.4.20 new method.

* Tue Feb 25 2014 - Damien Caliste <dcaliste@free.fr> 0.3-1
- add a way to cancel current network request.

* Wed Feb 19 2014 - Damien Caliste <dcaliste@free.fr> 0.2.1-1
- use a shared model for call page and call cover, so cover is properly updated.
- correct an issue with the date of last refresh.

* Tue Feb 18 2014 - Damien Caliste <dcaliste@free.fr> 0.2-1
- add off-line storage of the Freebox call list.
- add an cover displaying the call list.

* Thu Feb 06 2014 - Damien Caliste <dcaliste@free.fr> 0.1-1
- initial packaging, provide call log functionality.
