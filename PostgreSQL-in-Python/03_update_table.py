from django.forms import ImageField
import psycopg2
from psqlConfig import config

def update_vendor(vendor_id, vendor_name):
    """ update vendor name based on the vendor id """
    sql = """
    UPDATE vendors SET vendor_name = %s
    WHERE vendor_id = %s
    """

    conn = None
    update_rows = 0

    try:
        params = config()
        conn = psycopg2.connect(**params)

        cur = conn.cursor()
        cur.execute(sql, (vendor_name, vendor_id))
        update_rows = cur.rowcount
        conn.commit()
        cur.close()

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)

    finally:
        if conn is not None:
            conn.close()

    return update_rows

if __name__ == '__main__':
    # update vendor id 1
    update_vendor(1, "3M Corp")
