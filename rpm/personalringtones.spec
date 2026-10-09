Name:       personalringtones

Summary:    Personal ringtones
Version:    1.3.0
Release:    1
Group:      Qt/Qt
License:    WTFPL
URL:        http://github.com/coderus/personalringtones
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   voicecall-qt5
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(ngf-qt5)
BuildRequires:  pkgconfig(mlite5)
BuildRequires:  voicecall-qt5-devel
BuildRequires:  desktop-file-utils
BuildRequires:  sailfish-svg2png

%description
Application for assigning personal ringtones


%prep
%setup -q -n %{name}-%{version}

%build

%qmake5

make %{?_smp_mflags}

pushd plugin
%qmake5
make %{?_smp_mflags}
popd

%install
rm -rf %{buildroot}
%qmake5_install

pushd plugin
%qmake5_install
popd

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
%{_libdir}/voicecall/plugins/libvoicecall-angf-plugin.so

%changelog
* Thu Oct 08 2026 Denis Robel <denis.robel@gmx.de> - 1.3.0-1
- Build the voicecall plugin from source against the target's voicecall
  headers (fixes ABI break on Sailfish OS 5.x)
- Play ringtone only when requested by the call UI (playRingtoneRequested)
- Keep contact/SIM ringtone passed by the call UI as fallback
