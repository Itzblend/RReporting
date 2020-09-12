import config
import psycopg2
import sys
import os
import shutil

def _set_config():
    conf = config.get_config()

    dbname = conf.db_settings['dbname']
    dbuser = conf.db_settings['dbuser']
    dbhost = conf.db_settings['dbhost']
    dbpassword = conf.db_settings['password']
    dbport = conf.db_settings['port']

    global CONNECTION_STRING
    CONNECTION_STRING = f'dbname={dbname} user={dbuser} host={dbhost} password={dbpassword} port={dbport}'

    global SQL_CONFIG
    SQL_CONFIG = conf.sql_config

def _fetch_tickets():
    conn = psycopg2.connect(CONNECTION_STRING)
    cur = conn.cursor()

    cwd = os.getcwd()
    data_folder = f'{cwd}/data'
    shutil.rmtree(data_folder, ignore_errors=True)
    os.makedirs(data_folder, exist_ok=False)

    csvfile = f'{data_folder}/jira_tickets.csv'
    open(csvfile, 'w')


    query = f"""COPY {SQL_CONFIG['JIRA_DAILY_STATUSES']} TO STDOUT DELIMITER ',' CSV HEADER"""

    with open(csvfile, 'w') as f:
        cur.copy_expert(query, f)

    conn.commit()
    cur.close()
    conn.close()



def main():
    _set_config()
    _fetch_tickets()


if __name__ == '__main__':
    main()