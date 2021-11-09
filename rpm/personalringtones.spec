Name:       personalringtones

Summary:    Personal ringtones
Version:    1.2.4
Release:    1
Group:      Qt/Qt
License:    WTFPL
URL:        http://github.com/coderus/personalringtones
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils
BuildRequires:  sailfish-svg2png

%description
Application for assigning personal ringtones


%prep
%setup -q -n %{name}-%{version}

%build

%qmake5 

make %{?_smp_mflags}

%install
rm -rf %{buildroot}
%qmake5_install

desktop-file-install --delete-original \
  --dir %{buildroot}%{_datadir}/applications \
   %{buildroot}%{_datadir}/applications/*.desktop

%post
systemctl-user restart ngfd.service || :
systemctl-user restart voicecall-manager.service || :

%postun
systemctl-user restart ngfd.service || :
systemctl-user restart voicecall-manager.service || :

%files
%defattr(-,root,root,-)
%{_bindir}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
%{_datadir}/mapplauncherd/privileges.d/%{name}.privileges
%{_datadir}/ngfd/events.d/personal_ringtone.ini
%{_datadir}/ngfd/events.d/important_ringtone.ini
%{_libdir}/voicecall/plugins/*.so
