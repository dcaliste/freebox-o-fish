# RPM spec file for (Free) Box-o-fish.
# This file is used to build Redhat Package Manager packages for
# Maep.  Such packages make it easy to install and uninstall
# the library and related files from binaries or source.
#
# RPM. To build, use the command: rpmbuild --clean -ba maep-qt.spec
#

Name: harbour-freebox-o-fish

Summary: A Freebox compagnon
Version: 0.1
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

%files
%defattr(-,root,root,-)
/usr/share/applications
/usr/share/icons
/usr/share/%{name}
/usr/bin

%changelog
* Thu Feb 06 2014 - Damien Caliste <dcaliste@free.fr> 0.1-1
- initial packaging, provide call log functionality.
