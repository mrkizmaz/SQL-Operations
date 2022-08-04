import psycopg2
from psqlConfig import config

def connect():

    try: 
        """ Connect to the PostgreSQL database server """
        params = config()

        # connect to the psql server
        print('Connecting to the psql database...')
        conn = psycopg2.connect(**params)

        # create a cursor
        cur = conn.cursor()

        # execute a statement
        print('PostgreSQL database version:')
        cur.execute('SELECT version()')

        # display the psql database server version
        db_version = cur.fetchone()
        print(db_version)

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    
    finally:
        if conn is None:
            conn.close()
            print('Database connection closed.')

if __name__ == '__main__':
    connect()