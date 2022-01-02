TODO
----

- [x] Lock down SSH by default, disable password and root login ~~and enable fail2ban~~
  - Turns out that root login is semi-disabled via authorized_keys command and password login is already disabled
- [x] Security group for Quay
- [x] Quay installation via Ansible worked out
- [x] Bastion host creation on disconnected VPC
  - Need to find best way to get CA from squid to bastion
  - Need to describe how to ssh to bastion through proxy or registry (routing is otherwise borked, due to differing source IPs)
- [ ] Validate connectivity between bastion and Quay
  - This may require a private hosted zone
- [ ] Automate quay organization creation
- [ ] Validate oc-mirror workflows e2e
