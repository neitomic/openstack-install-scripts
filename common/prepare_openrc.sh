PARENT_DIR=$( cd `dirname $0`/.. && pwd )
BASE_DIR=${BASE_DIR:-$PARENT_DIR}

sed -i "s/ADMIN_PASS/${ADMIN_PASS}/g" ${BASE_DIR}/admin-openrc.sh
sed -i "s/DEMO_PASS/${DEMO_PASS}/g" ${BASE_DIR}/demo-openrc.sh