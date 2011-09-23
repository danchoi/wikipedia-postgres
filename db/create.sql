drop table if exists pages cascade;
drop table if exists categories cascade;
drop table if exists categorizations cascade;

create table pages (
  page_id integer primary key,
  title varchar,
  revision_id integer not null,
  revision_timestamp timestamp,
  page_text text
);

create table categories (
  category_id serial primary key,
  title varchar unique
);

create table categorizations (
  category_id integer references categories,
  page_id integer references pages
);
