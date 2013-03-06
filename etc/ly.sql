CREATE TABLE calendar (
    id integer NOT NULL,
    date timestamp without time zone,
    "time" text,
    type text,
    name text,
    committee text[],
    summary text,
    data pg_catalog.json,
    ad integer,
    session integer,
    sitting integer,
    raw pg_catalog.json,
    chair text,
    extra integer
);

CREATE UNIQUE INDEX "calendar_id" ON "calendar" USING btree (id);
CREATE INDEX "calendar_date" ON "calendar" USING btree (date);
CREATE INDEX "calendar_session" ON "calendar" USING btree (ad, session, committee, sitting);

-- pgrest views

CREATE SCHEMA pgrest;

CREATE OR REPLACE VIEW pgrest.calendar AS                                                                                                      SELECT id, date, "time", type, chair, name, committee, summary, ad, session, sitting FROM public.calendar WHERE (ad IS NOT NULL);

CREATE OR REPLACE VIEW pgrest.bills AS select * from public.bills;
CREATE OR REPLACE VIEW pgrest.motions AS select * from public.motions;
