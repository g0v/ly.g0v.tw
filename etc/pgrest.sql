--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: pgrest; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgrest;


SET search_path = pgrest, pg_catalog;

--
-- Name: bills; Type: VIEW; Schema: pgrest; Owner: -
--

CREATE VIEW bills AS
    SELECT bills.bill_id, bills.summary, bills.abstract, bills.proposer, bills.proposal, bills.petition, bills.data, bills.id, bills."createdAt", bills."updatedAt" FROM public.bills;


--
-- Name: calendar; Type: VIEW; Schema: pgrest; Owner: -
--

CREATE VIEW calendar AS
    SELECT calendar.id, (calendar.date)::date AS date, calendar."time", calendar.type, calendar.chair, calendar.name, calendar.committee, calendar.summary, calendar.ad, calendar.session, calendar.sitting FROM public.calendar WHERE (calendar.ad IS NOT NULL);


--
-- Name: ivod; Type: VIEW; Schema: pgrest; Owner: -
--

CREATE VIEW ivod AS
    SELECT ivod.ad, ivod.sitting, ivod.video_url_n, ivod.summary, ivod.session, ivod.video_url_w, ivod.committee, ivod."time", ivod.extra FROM public.ivod;


--
-- Name: meetings; Type: VIEW; Schema: pgrest; Owner: -
--

CREATE VIEW meetings AS
    SELECT meetings.session_id, meetings.sitting, meetings.committee, meetings.date, meetings.id, meetings."createdAt", meetings."updatedAt" FROM public.meetings;


--
-- Name: motions; Type: VIEW; Schema: pgrest; Owner: -
--

CREATE VIEW motions AS
    SELECT motions.bill_id, motions.mtype, motions.meeting, motions.dtype, motions.result, motions.resolution, motions.status, motions.misc, motions.item, motions."subItem", motions."exItem", motions."agendaItem", motions.id, motions."createdAt", motions."updatedAt" FROM public.motions;


--
-- PostgreSQL database dump complete
--

