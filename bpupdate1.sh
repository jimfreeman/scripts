#!/bin/bash
######################################################################
### OnApp vCD - Update Users and Org's to use central billing plan ###
######################################################################
#Created by Jim Freeman [jim.freeman@onapp.com]
#
db_conf="/onapp/interface/config/database.yml"
db_host=`cat $db_conf | grep host | awk '{print $2}' | head -n 1`
db_user=`cat $db_conf | grep username | awk '{print $2}' | head -n 1`
db_pass=`cat $db_conf | grep password | awk '{print $2}' | head -n 1`

echo -n "Which User plan do you want to use? "
read user_plan_id
nohup mysql -h $db_host -u$db_user -p$db_pass onapp -e "UPDATE user_groups_billing_plans set billing_plan_id=$user_plan_id;" > /dev/null 2>&1 && echo "All Organizations have been updated" || echo "Organizations have not been updated"
nohup mysql -h $db_host -u$db_user -p$db_pass onapp -e "UPDATE users set billing_plan_id=$user_plan_id;" > /dev/null 2>&1 && echo "All Users have been updated" || echo "Users have not been updated"
echo -n "Do you want to clean up all other billing plans? [y/n] "
read delete_user_plans
if echo "$delete_user_plans" | grep -iq "^y" ;then
nohup mysql -h $db_hst -u$db_user -p$db_pass onapp -e "DELETE FROM billing_plans where id NOT IN ($user_plan_id,2,3)" > /dev/null 2>&1 && echo "Billing Plans have been cleaned up" || echo "Billing Plans have not been cleaned up"
nohup mysql -h $db_host -u$db_user -p$db_pass onapp -e "UPDATE count_resources SET count= (SELECT COUNT(*) FROM billing_plans) where resource_type='billing_plans'" > /dev/null 2>&1 && echo "Billing Plan Counts Updated" || echo "Billing Plan Counts have not been updated"
else
echo "OK, no problem!"
fi
billing_plan_name=$(mysql -h $db_host -u$db_user -p$db_pass onapp -N -e "SELECT label from billing_plans where id=$user_plan_id")
echo "All Users and Organizations now use the Billing Plan: [$user_plan_id] [$billing_plan_name]"
