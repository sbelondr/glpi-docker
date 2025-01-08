-- Give right for glpi user
GRANT SELECT ON mysql.time_zone_name TO 'glpi'@'%';
FLUSH PRIVILEGES;
