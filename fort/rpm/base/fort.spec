Name:           fort
Version:        1.6.0
Release:        1%{?dist}
Summary:        RPKI validator and RTR server

# The source is MIT, only a section is BDS-2-clause (src/asn1/asn1c/*)
License:        MIT and BSD
URL:            https://nicmx.github.io/FORT-validator
Source0:        https://github.com/NICMx/FORT-validator/releases/download/%{version}/%{name}-%{version}.tar.gz
Source1:        https://github.com/NICMx/FORT-validator/releases/download/%{version}/%{name}-%{version}.tar.gz.asc
Source2:        https://github.com/NICMx/FORT-validator/releases/download/%{version}/%{name}-%{version}.keyring
Source3:        %{name}.service
Source4:        config.json
Source5:        default.slurm

%if 0%{?fedora}
BuildRequires:  systemd-rpm-macros
%endif
%if 0%{?rhel}
BuildRequires:  epel-rpm-macros
%endif
# Unexistent at OpenSUSE (see https://en.opensuse.org/openSUSE:Package_source_verification)
%if 0%{?rhel}%{?fedora}
BuildRequires:  gnupg2
%endif
BuildRequires:  gcc >= 4.9
BuildRequires:  make
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  pkgconfig
BuildRequires:  pkgconfig(jansson)
BuildRequires:  pkgconfig(libcurl)
BuildRequires:  libxml2-devel
%if 0%{?rhel} == 7
BuildRequires:  pkgconfig(openssl11)
BuildRequires:  devtoolset-8-gcc
%else
BuildRequires:  openssl-devel >= 1.1.0
%endif

Requires(pre):  shadow-utils
Requires:       rsync

ExclusiveArch:  x86_64

%description
FORT validator is an RPKI Relying Party software: it performs the
validation of the RPKI repository and serves the ROAs to the routers.
It's part of the FORT project (https://www.fortproject.net/).

%global _hardened_build 1

%prep
%if 0%{?rhel}%{?fedora}
%{gpgverify} --keyring='%{SOURCE2}' --signature='%{SOURCE1}' --data='%{SOURCE0}'
%endif
%autosetup

%build
export CFLAGS+=" -Wall -pedantic"
export LDFLAGS+=" -Wl,--as-needed"
%if 0%{?rhel} == 7
export CFLAGS+=" $(pkg-config --cflags openssl11)"
export LDFLAGS+=" $(pkg-config --libs openssl11)"
scl enable devtoolset-8 -- <<\EOF
%endif
%configure
%make_build
%if 0%{?rhel} == 7
EOF
%endif

%install
%make_install
%{__mkdir} -p %{buildroot}/%{_unitdir}
%{__mkdir} -p %{buildroot}/%{_sysconfdir}/%{name}/{tal,slurm}
%{__mkdir} -p %{buildroot}/%{_sysconfdir}/systemd/system/%{name}.service.d
%{__mkdir} -p %{buildroot}/%{_sharedstatedir}/%{name}/{examples,repository}
%{__install} -m644 %{SOURCE3} %{buildroot}/%{_unitdir}/%{name}.service
%{__install} -m644 %{SOURCE4} %{buildroot}/%{_sysconfdir}/%{name}/config.json
%{__install} -m644 examples/tal/*.tal %{buildroot}/%{_sysconfdir}/%{name}/tal
%{__install} -m644 %{SOURCE5} %{buildroot}/%{_sysconfdir}/%{name}/slurm
%{__install} -m644 examples/*.* %{buildroot}/%{_sharedstatedir}/%{name}/examples
printf 'Signature: 8a477f597d28d172789f06886806bc55' > %{buildroot}/%{_sharedstatedir}/%{name}/repository/CACHEDIR.TAG

%clean
%{__rm} -rf %{buildroot}

%files
%license NOTICE LICENSE
%config(noreplace) /etc/fort/config.json
%config(noreplace) /etc/fort/tal/*.tal
%config(noreplace) /etc/fort/slurm/*.slurm
%docdir /var/lib/fort/examples
%{_sharedstatedir}/%{name}/examples/*.*
%{_bindir}/%{name}
%{_mandir}/man8/fort.8*
%{_unitdir}/%{name}.service
%{_sharedstatedir}/%{name}/repository/CACHEDIR.TAG

%pre
getent group fort >/dev/null || groupadd -r fort
getent passwd fort >/dev/null || \
    useradd -r -g fort -M -d %{_sharedstatedir}/%{name} -s /sbin/nologin \
    -c "FORT validator" fort
exit 0

%post
if [ $1 -eq 1 ]; then
    /usr/bin/systemctl preset fort.service >/dev/null 2>&1 ||:
    chown -R fort:fort %{_sharedstatedir}/%{name} >/dev/null 2>&1||:
fi

%preun
/usr/bin/systemctl --no-reload disable fort.service >/dev/null 2>&1 ||:
/usr/bin/systemctl stop fort.service >/dev/null 2>&1 ||:

%postun
if [ $1 -eq 0 ]; then
    %{__rm} -rf %{_sharedstatedir}/%{name}
fi

%changelog
* Thu Nov 30 2023 Alberto Leiva Popper <ydahhrk@gmail.com> - 1.6.0-1
- New upstream release.
* Wed Jul 05 2023 Alberto Leiva Popper <ydahhrk@gmail.com> - 1.5.4-1
- New upstream release.
* Mon Nov 08 2021 Alberto Leiva Popper <ydahhrk@gmail.com> - 1.5.3-1
- New upstream release.
* Wed Oct 20 2021 Alberto Leiva Popper <ydahhrk@gmail.com> - 1.5.2-1
- New upstream release.
* Tue Dec 15 2020 Francisco Moreno <pc.moreno2099@gmail.com> - 1.5.0-1
- New upstream release.
- Add 'RestartForceExitStatus' service setting.
* Tue Oct 20 2020 Francisco Moreno <pc.moreno2099@gmail.com> - 1.4.2-1
- First official FORT validator RPM

