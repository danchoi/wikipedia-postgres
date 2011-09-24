set default_tablespace = wikipedia_space;
create language plpgsql;
drop table if exists pages cascade;
drop table if exists categories cascade;
drop table if exists categorizations cascade;

create table pages (
  page_id integer primary key,
  page_title varchar,
  revision_id integer not null,
  revision_timestamp timestamp,
  page_text text,
  page_length integer,
  textsearchable tsvector
);
CREATE INDEX pages_textsearch_idx ON pages USING gin(textsearchable);

CREATE OR REPLACE FUNCTION calc_page_length() RETURNS trigger AS $$
  BEGIN
    NEW.page_length := length(NEW.page_text);
    return NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cal_page_length BEFORE INSERT OR UPDATE ON pages FOR EACH ROW EXECUTE PROCEDURE calc_page_length();

CREATE OR REPLACE FUNCTION pages_update_tsvector() RETURNS trigger AS $$
BEGIN
  new.textsearchable :=
     setweight(to_tsvector('pg_catalog.english', coalesce(new.page_title,'')), 'A') ||
     setweight(to_tsvector('pg_catalog.english', coalesce(new.page_text,'')), 'B');
  return new;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER pages_update_tsvector BEFORE INSERT OR UPDATE ON pages FOR EACH ROW EXECUTE PROCEDURE pages_update_tsvector();



create table categories (
  category_id serial primary key,
  category_title varchar unique
);

create table categorizations (
  category_id integer references categories,
  page_id integer references pages
);
