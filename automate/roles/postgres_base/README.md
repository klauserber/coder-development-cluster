# postgres_base

Role to deploy the Zalando Postgres operator in k8s.

See: https://postgres-operator.readthedocs.io/en/latest/

## Requirements

none

## Role Variables

```yaml
pg_operator_namespace: "postgres"
pg_operator_state: "present"
pg_operator_chart_version: "1.8.2"
pg_operator_chart_ref: "postgres-operator-charts/postgres-operator"

pg_operator_resync_period: "5m"
```

## Dependencies

none

## Example Playbook

```yaml
- hosts: "localhost"
  gather_facts: false
  vars:
    provider: "ionos"
    env_id: "000"
    stage: "mgmt"
    kubeconfig_path: "~/.kube/config"
  roles:
    - "infrastructure_configuration"
    - "postgres_base"
```

## License

UNDEFINED

## Author Information

Klaus Erber <k.erber@erber-freelance.de>