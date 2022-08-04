import psycopg2
from psqlConfig import config

def truncate_table(table_name):
    """ truncate table """
    sql = f"""
    TRUNCATE TABLE {table_name} RESTART IDENTITY CASCADE;
    """

    conn = None

    try:
        params = config()
        conn = psycopg2.connect(**params)

        cur = conn.cursor()
        cur.execute(sql)
        conn.commit()
        cur.close()

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)

    finally:
        if conn is not None:
            conn.close()

            
if __name__ == '__main__':
    truncate_table("vendors")