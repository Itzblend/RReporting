from collections import namedtuple
import os
import json


# Configs for getting jira issues on CSV


def get_config():

    # IMPORTANT! If you change creds file name, edit gitignore file accordingly
    os.system('vault read database/creds/rreport_service -format=json > creds.json')
    with open('creds.json', 'r') as file:
        creds = json.load(file)

        db_settings = {
            'dbhost': os.popen("vault kv get -field=dbhost kv/postgres").read(),
            'dbname': 'jira',
            'dbuser': os.popen("vault kv get -field=dbuser kv/postgres").read(),
            'password': os.popen("vault kv get -field=password kv/postgres").read(),
            'port': os.popen("vault kv get -field=port kv/postgres").read()
        }

    schema = 'kafka'
    schema_tables = f'{schema}_t'

    sql_config = {
        'SCHEMA': schema,
        'SCHEMA_TABLES': schema_tables,
        'READERS': 'readers',
        'JIRA_ISSUES_TABLE': f'{schema_tables}.jira_issues_t',
        'JIRA_ISSUES_VIEW': f'{schema}.jira_issues',
        'JIRA_DAILY_STATUSES': f'{schema_tables}.jira_daily_statuses_t',
        'JIRA_DAILY_STATUSES_VIEW': f'{schema}.jira_daily_statuses',
        'JIRA_ISSUES_CURRENT': f'{schema}.jira_issues_current'
    }

    conf = namedtuple('conf', ['db_settings', 'sql_config'])

    return conf(db_settings=db_settings, sql_config=sql_config)