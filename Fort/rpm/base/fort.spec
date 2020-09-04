Name:           fort
Version:        1.4.1
Release:        1%{?dist}
Summary:        RPKI validator and RTR server
Packager:       FORT Validator <fort-validator@nic.mx>

# The source is MIT, only a section is BDS-2-clause (src/asn1/asn1c/*)
License:        MIT and BSD
URL:            https://nicmx.github.io/FORT-validator
Source0:        https://github.com/NICMx/FORT-validator/releases/download/v%{version}/%{name}-%{version}.tar.gz
Source1:        %{name}.service
Source2:        config.json

BuildRequires:  gcc >= 4.9
BuildRequires:  make
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  pkgconfig
BuildRequires:  jansson-devel
BuildRequires:  libcurl-devel
BuildRequires:  libxml2-devel
BuildRequires:  openssl-devel >= 1.1.0

Requires(pre):  shadow-utils
Requires:       rsync
Requires:       openssl >= 1.1.0

ExclusiveArch:  x86_64

%description
FORT validator is an RPKI Relying Party software: it performs the
validation of the RPKI repository and serves the ROAs to the routers.
It's part of the FORT project (https://www.fortproject.net/).

%prep
%autosetup

%build
export CFLAGS+='-Wall -pedantic'
export LDFLAGS+='-Wl,--as-needed'
%configure
%make_build

%install
%make_install
%{__mkdir} -p %{buildroot}/%{_unitdir}
%{__mkdir} -p %{buildroot}/%{_sysconfdir}/%{name}/{tal,slurm}
%{__mkdir} -p %{buildroot}/%{_sysconfdir}/systemd/system/%{name}.service.d
%{__mkdir} -p %{buildroot}/%{_sharedstatedir}/%{name}/{examples,repository}
%{__install} -m644 %{SOURCE1} %{buildroot}/%{_unitdir}/%{name}.service
%{__install} -m644 %{SOURCE2} %{buildroot}/%{_sysconfdir}/%{name}/config.json
%{__install} -m644 examples/tal/*.tal %{buildroot}/%{_sysconfdir}/%{name}/tal
%{__install} -m644 examples/*.* %{buildroot}/%{_sharedstatedir}/%{name}/examples
printf 'Signature: 8a477f597d28d172789f06886806bc55' > %{buildroot}/%{_sharedstatedir}/%{name}/repository/CACHEDIR.TAG

%clean
%{__rm} -rf %{buildroot}

%files
%license NOTICE LICENSE
%config(noreplace) /etc/fort/config.json
%config(noreplace) /etc/fort/tal/*.tal
%docdir /var/lib/fort/examples
%{_sharedstatedir}/%{name}/examples/*.*
%{_bindir}/%{name}
%{_mandir}/man8/fort.8*
%{_unitdir}/fort.service
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
fi

%preun
/usr/bin/systemctl --no-reload disable fort.service >/dev/null 2>&1 ||:
/usr/bin/systemctl stop fort.service >/dev/null 2>&1 ||:

%postun
if [ $1 -eq 0 ]; then
    %{__rm} -rf %{_sharedstatedir}/%{name}
fi

%changelog
* Wed Sep 02 2020 Francisco Moreno <pc.moreno2099@gmail.com> - 1.4.1-1
- First offica FORT validator RPM