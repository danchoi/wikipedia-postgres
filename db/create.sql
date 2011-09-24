create language plpgsql;
drop table if exists pages cascade;
drop table if exists categories cascade;
drop table if exists categorizations cascade;

create table pages (
  page_id integer primary key,
  title varchar,
  revision_id integer not null,
  revision_timestamp timestamp,
  page_text text,
  page_length integer 
);

CREATE OR REPLACE FUNCTION calc_page_length() RETURNS trigger AS $$
  BEGIN
    NEW.page_length := length(NEW.page_text);
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cal_page_length BEFORE INSERT OR UPDATE ON pages FOR EACH ROW EXECUTE PROCEDURE calc_page_length();

create table categories (
  category_id serial primary key,
  title varchar unique
);

create table categorizations (
  category_id integer references categories,
  page_id integer references pages
);
