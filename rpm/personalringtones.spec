Name:       personalringtones

# >> macros
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    Personal Ringtones
Version:    0.3.1
Release:    1
Group:      Qt/Qt
License:    WTFPL
URL:        https://github.com/CODeRUS/personal-ringtones
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
Conflicts:  harbour-personal-ringtones
Obsoletes:  harbour-personal-ringtones
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(TelepathyQt5)
BuildRequires:  pkgconfig(dconf)
BuildRequires:  pkgconfig(Qt5SystemInfo)
BuildRequires:  pkgconfig(qofono-qt5)
BuildRequires:  desktop-file-utils

%description
Simple proof-of-concept hacky-tricky service and settings applet for
 customizing ringtones per contact

%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5  \
    VERSION=%{version}

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
mkdir -p %{buildroot}/usr/lib/systemd/user/post-user-session.target.wants
ln -s ../personalringtones.service %{buildroot}/usr/lib/systemd/user/post-user-session.target.wants/personalringtones.service
# << install post

%pre
# >> pre
systemctl-user stop personalringtones.service

if /sbin/pidof personalringtones > /dev/null; then
killall personalringtones || true
fi
# << pre

%preun
# >> preun
systemctl-user stop personalringtones.service

if /sbin/pidof personalringtones > /dev/null; then
killall personalringtones || true
fi
# << preun

%post
# >> post
systemctl-user restart personalringtones.service
# << post


%files
%defattr(-,root,root,-)
%{_bindir}/*
%{_datadir}/%{name}
%{_datadir}/dbus-1/services/org.coderus.personalringtones.service
%{_libdir}/systemd/user/personalringtones.service
%{_libdir}/systemd/user/post-user-session.target.wants/personalringtones.service
%{_datadir}/jolla-settings/entries
# >> files
# << files
