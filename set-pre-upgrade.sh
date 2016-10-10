# !/bin/bash

set -o xtrace


# Use run-upgrade to run only minimum set of playbooks
# Projects upgrade  prerequisites
sed -i "/RUN_TASKS.\=..*./,$ d" ./run-upgrade.sh

cat <<EOM >> ./run-upgrade.sh
        RUN_TASKS+=("\${UPGRADE_PLAYBOOKS}/ansible_fact_cleanup.yml")
        RUN_TASKS+=("\${UPGRADE_PLAYBOOKS}/deploy-config-changes.yml")
        RUN_TASKS+=("\${UPGRADE_PLAYBOOKS}/user-secrets-adjustment.yml")
        RUN_TASKS+=("\${UPGRADE_PLAYBOOKS}/db-collation-alter.yml")
        RUN_TASKS+=("\${UPGRADE_PLAYBOOKS}/pip-conf-removal.yml")
        RUN_TASKS+=("setup-hosts.yml --limit '!galera_all'")
        RUN_TASKS+=("repo-server.yml --tags 'repo-server'")
        RUN_TASKS+=("repo-build.yml")
        RUN_TASKS+=("\${UPGRADE_PLAYBOOKS}/old-hostname-compatibility.yml")
        RUN_TASKS+=("galera-install.yml -e 'galera_upgrade=true'")
        RUN_TASKS+=("utility-install.yml")
        RUN_TASKS+=("\${UPGRADE_PLAYBOOKS}/memcached-flush.yml")
        # Run the tasks in order
        for item in \${!RUN_TASKS[@]}; do
          run_lock \$item "\${RUN_TASKS[\$item]}"
        done
    popd
}

main

EOM

