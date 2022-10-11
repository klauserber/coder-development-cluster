# postgres_instance

Role to deploy the Zalando Postgres instance in k8s.

## Requirements

The cluster needs to have the Zalando Postgres operator deployed.

See this role to do that: https://git.dataport.de/phoenix/ionos/ansible-roles/postgres_base

## Role Variables

Documented defaults file: [defaults/main.yml](defaults/main.yml)

## Example Playbook

Minimal example: [examples/minimal.yml](examples/minimal.yml)

Example for a production deployment with high availibility, backup and restore: [examples/production.yml](examples/production.yml)

## License

UNDEFINED

## Author Information

Klaus Erber <k.erber@erber-freelance.de>

## Usage

### Connect to the database inside the cluster

The database will be accessible at the service end point `<pg_team_id>-<pg_instance_name>:5432`. To access the database from another pg_namespace include the pg_namespace from the database instance in the hostname: `<pg_team_id>-<pg_instance_name>.<pg_namespace of the the instance>:5432`

The password for the postgres user to manage the database instance is stored in the secret: `postgres.<pg_team_id>-<pg_instance_name>.credentials.postgresql.acid.zalan.do`

The passwords for the database users are stored in secrets named by the username like: `<username>.<pg_team_id>-<pg_instance_name>.credentials.postgresql.acid.zalan.do`

### Connect to the database from the local machine

Follow this documentation: https://postgres-operator.readthedocs.io/en/latest/user/#connect-to-postgresql

Or use the the script `connect_pg.sh`:

```bash
USAGE: ./pg_connect.sh <pg_namespace> <instance-name> <team_id> [port]
```

```bash
./connect_pg.sh default myteam myproddb-instance
port forward the postgres port with:
pg_namespace:              default
instance name:          myproddb-instance
team_id:                myteam
localhost port:         5432
pg master pod:          myteam-myproddb-instance-0
passwort postgres user: ...

connect to the database instance by using your favorite database tool like this:

psql -h localhost -U postgres -p 5432

Forwarding from 127.0.0.1:5432 -> 5432
```

### Backup

We are doing Continuous Archiving and Point-in-Time Recovery (PITR), see more at: https://www.postgresql.org/docs/current/continuous-archiving.html

Activate it with `pg_backup: true`

For advanced backup configuration options please refer to the the documented defaults file: [defaults/main.yml](defaults/main.yml)

### Restore

To pick up an existing backup at creation of a new database instance activate cloning with: `pg_clone: true`

For advanced clone configuration options please refer to the the documented defaults file: [defaults/main.yml](defaults/main.yml)