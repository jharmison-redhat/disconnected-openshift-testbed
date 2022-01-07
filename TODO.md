TODO
----

- [x] Lock down SSH by default, disable password and root login ~~and enable fail2ban~~
  - Turns out that root login is semi-disabled via authorized_keys command and password login is already disabled
- [x] Security group for Quay
- [x] Quay installation via Ansible worked out
- [x] Bastion host creation on disconnected VPC
- [x] Validate connectivity between bastion and Quay
- [ ] Automate quay organization creation
- [ ] Validate oc-mirror workflows e2e
