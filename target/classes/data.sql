INSERT INTO webappdb.user (userid, email_address, first_name, last_name, password, ssn, user_name) 
VALUES ("101", "kojitechs@gmail.com", "koji", "bello", "$2a$10$w.2Z0pQl9K5GOMVT.y2Jz.UW4Au7819nbzNh8nZIYhbnjCi6MG8Qu", "ssn101", "kojitechs");	
INSERT INTO webappdb.role (roleid, role) VALUES ("201", "ADMIN");
INSERT INTO webappdb.user_role (userid, roleid) VALUES ("101", "201");