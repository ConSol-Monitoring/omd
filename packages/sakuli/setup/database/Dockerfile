FROM mysql:5.5

MAINTAINER Tobias Schneck "tobias.schneck@consol.de"

ENV REFRESHED_AT 2015-04-23
ENV MYSQL_ROOT_PASSWORD=sakuli
ENV MYSQL_DATABASE=sakuli
ENV MYSQL_USER=sakuli
ENV MYSQL_PASSWORD=sakuli

# commands to start:
# docker build -t=toschneck/mysql-sakuli .
# docker run --name mysql-sakuli -p 3306:3306 toschneck/mysql-sakuli


#DID NOT WORKED :(
#CMD ["mysqld"]
#CMD ["/usr/local/mysql/bin/mysql -u sakuli -p sakuli sakuli <  \/sakuli-inst\/create_sakuli_database.sql"]
EXPOSE 3306
