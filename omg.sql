CREATE DATABASE mongodb_insurance_model
	ENCODING UTF8
	TABLESPACE 'pg_default';

CREATE SCHEMA IF NOT EXISTS omg;
SET search_path TO omg;

CREATE TABLE IF NOT EXISTS omg.agreement (
	agreement_identifier integer NOT NULL,
	agreement_name varchar(100),
	agreement_original_inception_date timestamp WITHOUT TIME ZONE,
	product_identifier integer,
	agreement_type_code varchar(5),
	CONSTRAINT agreement_pkey PRIMARY KEY (agreement_identifier)
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.party (
	party_identifier bigint NOT NULL,
	party_name varchar(100),
	begin_date timestamp WITHOUT TIME ZONE,
	end_date timestamp WITHOUT TIME ZONE,
	party_type_code char(1),
	CONSTRAINT party_pkey PRIMARY KEY (party_identifier)
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.agreement_party_role (
	agreement_identifier integer NOT NULL,
	party_identifier bigint NOT NULL,
	party_role_code varchar(20) NOT NULL,
	effective_date timestamp WITHOUT TIME ZONE,
	expiration_date timestamp WITHOUT TIME ZONE,
	CONSTRAINT agreement_party_role_pkey PRIMARY KEY (agreement_identifier, party_identifier, party_role_code),
	CONSTRAINT party FOREIGN KEY (party_identifier) REFERENCES omg.party (party_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT agreement FOREIGN KEY (agreement_identifier) REFERENCES omg.agreement (agreement_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.location_address (
	location_address_identifier integer NOT NULL,
	line_1_address varchar(200),
	municipality_name varchar(100),
	line_2_address varchar(200),
	postal_code varchar(20),
	country_code char(3),
	state_code char(2),
	begin_date timestamp WITHOUT TIME ZONE,
	end_date timestamp WITHOUT TIME ZONE,
	CONSTRAINT location_address_pkey PRIMARY KEY (location_address_identifier)
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.insurable_object (
	insurable_object_identifier integer NOT NULL,
	location_address_identifier integer,
	insurable_object_type_code varchar(20),
	CONSTRAINT insurable_object_pkey PRIMARY KEY (insurable_object_identifier),
	CONSTRAINT "location address" FOREIGN KEY (location_address_identifier) REFERENCES omg.location_address (location_address_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.claim (
	claim_identifier integer NOT NULL,
	catastrophe_identifier integer,
	claim_description varchar(5000),
	claims_made_date timestamp WITHOUT TIME ZONE,
	company_claim_number varchar(20),
	company_subclaim_number varchar(50),
	insurable_object_identifier integer,
	occurrence_identifier integer,
	entry_into_claims_made_program_date timestamp WITHOUT TIME ZONE,
	claim_open_date timestamp WITHOUT TIME ZONE,
	claim_close_date timestamp WITHOUT TIME ZONE,
	claim_reopen_date timestamp WITHOUT TIME ZONE,
	claim_status_code varchar(10),
	claim_reported_date timestamp WITHOUT TIME ZONE,
	CONSTRAINT claim_pkey PRIMARY KEY (claim_identifier),
	CONSTRAINT "insurable object" FOREIGN KEY (insurable_object_identifier) REFERENCES omg.insurable_object (insurable_object_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.party_role (
	party_role_code varchar(20) NOT NULL,
	party_role_name varchar(100),
	party_role_description varchar(2000),
	CONSTRAINT party_role_pkey PRIMARY KEY (party_role_code)
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.claim_party_role (
	claim_identifier integer NOT NULL,
	party_role_code varchar(20) NOT NULL,
	begin_date timestamp WITHOUT TIME ZONE NOT NULL,
	party_identifier bigint NOT NULL,
	end_date timestamp WITHOUT TIME ZONE,
	CONSTRAINT claim_party_role_pkey PRIMARY KEY (claim_identifier, party_role_code, begin_date, party_identifier),
	CONSTRAINT claim FOREIGN KEY (claim_identifier) REFERENCES omg.claim (claim_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT party FOREIGN KEY (party_identifier) REFERENCES omg.party (party_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT "party role" FOREIGN KEY (party_role_code) REFERENCES omg.party_role (party_role_code) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.grouping (
	grouping_identifier bigint NOT NULL,
	grouping_name varchar(100),
	CONSTRAINT grouping_pkey PRIMARY KEY (grouping_identifier),
	CONSTRAINT party FOREIGN KEY (grouping_identifier) REFERENCES omg.party (party_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.insurable_object_party_role (
	insurable_object_identifier integer NOT NULL,
	party_role_code varchar(20) NOT NULL,
	effective_date timestamp WITHOUT TIME ZONE NOT NULL,
	party_identifier bigint NOT NULL,
	expiration_date timestamp WITHOUT TIME ZONE,
	CONSTRAINT insurable_object_party_role_pkey PRIMARY KEY (insurable_object_identifier, party_role_code, effective_date, party_identifier),
	CONSTRAINT party FOREIGN KEY (party_identifier) REFERENCES omg.party (party_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT "insurable object" FOREIGN KEY (insurable_object_identifier) REFERENCES omg.insurable_object (insurable_object_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.litigation (
	litigation_identifier integer NOT NULL,
	court_identifier integer,
	jurisdiction_identifier integer,
	litigation_description varchar(5000),
	CONSTRAINT litigation_pkey PRIMARY KEY (litigation_identifier)
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.litigation_party_role (
	litigation_identifier integer NOT NULL,
	party_identifier bigint NOT NULL,
	party_role_code varchar(20) NOT NULL,
	begin_date timestamp WITHOUT TIME ZONE NOT NULL,
	claim_identifier integer NOT NULL,
	end_date timestamp WITHOUT TIME ZONE,
	CONSTRAINT litigation_party_role_pkey PRIMARY KEY (litigation_identifier, party_identifier, party_role_code, begin_date, claim_identifier),
	CONSTRAINT party FOREIGN KEY (party_identifier) REFERENCES omg.party (party_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT litigation FOREIGN KEY (litigation_identifier) REFERENCES omg.litigation (litigation_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT claim FOREIGN KEY (claim_identifier) REFERENCES omg.claim (claim_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT "party role" FOREIGN KEY (party_role_code) REFERENCES omg.party_role (party_role_code) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.organization (
	organization_identifier bigint NOT NULL,
	industry_code varchar(20),
	organization_name varchar(100),
	dun_and_bradstreet_identifier integer,
	organization_type_code varchar(20),
	alternate_name varchar(200),
	organization_description varchar(5000),
	acronym_name varchar(40),
	industry_type_code varchar(10),
	CONSTRAINT organization_pkey PRIMARY KEY (organization_identifier),
	CONSTRAINT party FOREIGN KEY (organization_identifier) REFERENCES omg.party (party_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.party_location_address (
	party_identifier integer NOT NULL,
	location_address_identifier integer NOT NULL,
	preferred_indicator char(1),
	CONSTRAINT party_location_address_pkey PRIMARY KEY (party_identifier, location_address_identifier),
	CONSTRAINT party FOREIGN KEY (party_identifier) REFERENCES omg.party (party_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT "location address" FOREIGN KEY (location_address_identifier) REFERENCES omg.location_address (location_address_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.person (
	person_identifier bigint NOT NULL,
	first_name varchar(40),
	middle_name varchar(40),
	last_name varchar(40),
	full_legal_name varchar(100),
	nickname varchar(40),
	suffix_name varchar(20),
	birth_date timestamp WITHOUT TIME ZONE,
	birth_place_name varchar(100),
	gender_code char(1),
	prefix_name varchar(20),
	CONSTRAINT person_pkey PRIMARY KEY (person_identifier),
	CONSTRAINT party FOREIGN KEY (person_identifier) REFERENCES omg.party (party_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.policy (
	policy_identifier integer NOT NULL,
	effective_date timestamp WITHOUT TIME ZONE,
	expiration_date timestamp WITHOUT TIME ZONE,
	policy_number varchar(50),
	status_code varchar(20),
	location_address_identifier integer,
	CONSTRAINT policy_pkey PRIMARY KEY (policy_identifier)
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.policy_coverage_part (
	coverage_part_code varchar(20) NOT NULL,
	policy_identifier integer NOT NULL,
	CONSTRAINT policy_coverage_part_pkey PRIMARY KEY (coverage_part_code, policy_identifier),
	CONSTRAINT policy FOREIGN KEY (policy_identifier) REFERENCES omg.policy (policy_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.policy_coverage_detail (
	effective_date timestamp WITHOUT TIME ZONE NOT NULL,
	policy_coverage_detail_identifier integer NOT NULL,
	coverage_identifier integer,
	insurable_object_identifier integer,
	policy_identifier integer,
	coverage_part_code varchar(20),
	coverage_description varchar(2000),
	expiration_date timestamp WITHOUT TIME ZONE,
	coverage_inclusion_exclusion_code char(1),
	CONSTRAINT policy_coverage_detail_pkey PRIMARY KEY (effective_date, policy_coverage_detail_identifier),
	CONSTRAINT "policy coverage part" FOREIGN KEY (coverage_part_code, policy_identifier) REFERENCES omg.policy_coverage_part (coverage_part_code, policy_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT "insurable object" FOREIGN KEY (insurable_object_identifier) REFERENCES omg.insurable_object (insurable_object_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.policy_deductible (
	policy_deductible_identifier integer NOT NULL,
	effective_date timestamp WITHOUT TIME ZONE,
	policy_coverage_detail_identifier integer,
	deductible_type_code varchar(20),
	deductible_value numeric,
	deductible_basis_code varchar(20),
	CONSTRAINT policy_deductible_pkey PRIMARY KEY (policy_deductible_identifier),
	CONSTRAINT "policy coverage detail" FOREIGN KEY (policy_coverage_detail_identifier, effective_date) REFERENCES omg.policy_coverage_detail (policy_coverage_detail_identifier, effective_date) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.policy_limit (
	policy_limit_identifier integer NOT NULL,
	effective_date timestamp WITHOUT TIME ZONE,
	policy_coverage_detail_identifier integer,
	limit_type_code varchar(20),
	limit_value numeric,
	limit_basis_code varchar(20),
	CONSTRAINT policy_limit_pkey PRIMARY KEY (policy_limit_identifier),
	CONSTRAINT "policy coverage detail" FOREIGN KEY (policy_coverage_detail_identifier, effective_date) REFERENCES omg.policy_coverage_detail (policy_coverage_detail_identifier, effective_date) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS omg.policy_party_role (
	policy_identifier integer NOT NULL,
	party_role_code varchar(20) NOT NULL,
	begin_date timestamp WITHOUT TIME ZONE NOT NULL,
	party_identifier bigint NOT NULL,
	agreement_indentifier integer,
	end_date timestamp WITHOUT TIME ZONE,
	CONSTRAINT policy_party_role_pkey PRIMARY KEY (policy_identifier, party_role_code, begin_date, party_identifier),
	CONSTRAINT policy FOREIGN KEY (policy_identifier) REFERENCES omg.policy (policy_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT "party role" FOREIGN KEY (party_role_code) REFERENCES omg.party_role (party_role_code) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT party FOREIGN KEY (party_identifier) REFERENCES omg.party (party_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT agreement FOREIGN KEY (agreement_indentifier) REFERENCES omg.agreement (agreement_identifier) MATCH SIMPLE ON DELETE NO ACTION ON UPDATE NO ACTION
) TABLESPACE pg_default;

CREATE UNIQUE INDEX IF NOT EXISTS agreement_pkey
 ON ONLY omg.agreement USING BTREE (agreement_identifier pg_catalog.int4_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS party_pkey
 ON ONLY omg.party USING BTREE (party_identifier pg_catalog.int8_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS agreement_party_role_pkey
 ON ONLY omg.agreement_party_role USING BTREE (agreement_identifier pg_catalog.int4_ops ASC NULLS LAST, party_identifier pg_catalog.int8_ops ASC NULLS LAST, party_role_code COLLATE pg_catalog."default" pg_catalog.text_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS location_address_pkey
 ON ONLY omg.location_address USING BTREE (location_address_identifier pg_catalog.int4_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS insurable_object_pkey
 ON ONLY omg.insurable_object USING BTREE (insurable_object_identifier pg_catalog.int4_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS claim_pkey
 ON ONLY omg.claim USING BTREE (claim_identifier pg_catalog.int4_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS party_role_pkey
 ON ONLY omg.party_role USING BTREE (party_role_code COLLATE pg_catalog."default" pg_catalog.text_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS claim_party_role_pkey
 ON ONLY omg.claim_party_role USING BTREE (claim_identifier pg_catalog.int4_ops ASC NULLS LAST, party_role_code COLLATE pg_catalog."default" pg_catalog.text_ops ASC NULLS LAST, begin_date pg_catalog.timestamp_ops ASC NULLS LAST, party_identifier pg_catalog.int8_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS grouping_pkey
 ON ONLY omg.grouping USING BTREE (grouping_identifier pg_catalog.int8_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS insurable_object_party_role_pkey
 ON ONLY omg.insurable_object_party_role USING BTREE (insurable_object_identifier pg_catalog.int4_ops ASC NULLS LAST, party_role_code COLLATE pg_catalog."default" pg_catalog.text_ops ASC NULLS LAST, effective_date pg_catalog.timestamp_ops ASC NULLS LAST, party_identifier pg_catalog.int8_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS litigation_pkey
 ON ONLY omg.litigation USING BTREE (litigation_identifier pg_catalog.int4_ops ASC NULLS LAST) ;

CREATE INDEX IF NOT EXISTS fki_litigation
 ON ONLY omg.litigation_party_role USING BTREE (litigation_identifier pg_catalog.int4_ops ASC NULLS LAST) ;

CREATE INDEX IF NOT EXISTS "fki_party role"
 ON ONLY omg.litigation_party_role USING BTREE (party_role_code COLLATE pg_catalog."default" pg_catalog.text_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS litigation_party_role_pkey
 ON ONLY omg.litigation_party_role USING BTREE (litigation_identifier pg_catalog.int4_ops ASC NULLS LAST, party_identifier pg_catalog.int8_ops ASC NULLS LAST, party_role_code COLLATE pg_catalog."default" pg_catalog.text_ops ASC NULLS LAST, begin_date pg_catalog.timestamp_ops ASC NULLS LAST, claim_identifier pg_catalog.int4_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS organization_pkey
 ON ONLY omg.organization USING BTREE (organization_identifier pg_catalog.int8_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS party_location_address_pkey
 ON ONLY omg.party_location_address USING BTREE (party_identifier pg_catalog.int4_ops ASC NULLS LAST, location_address_identifier pg_catalog.int4_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS person_pkey
 ON ONLY omg.person USING BTREE (person_identifier pg_catalog.int8_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS policy_pkey
 ON ONLY omg.policy USING BTREE (policy_identifier pg_catalog.int4_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS policy_coverage_part_pkey
 ON ONLY omg.policy_coverage_part USING BTREE (coverage_part_code COLLATE pg_catalog."default" pg_catalog.text_ops ASC NULLS LAST, policy_identifier pg_catalog.int4_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS policy_coverage_detail_pkey
 ON ONLY omg.policy_coverage_detail USING BTREE (effective_date pg_catalog.timestamp_ops ASC NULLS LAST, policy_coverage_detail_identifier pg_catalog.int4_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS policy_deductible_pkey
 ON ONLY omg.policy_deductible USING BTREE (policy_deductible_identifier pg_catalog.int4_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS policy_limit_pkey
 ON ONLY omg.policy_limit USING BTREE (policy_limit_identifier pg_catalog.int4_ops ASC NULLS LAST) ;

CREATE INDEX IF NOT EXISTS fki_agreement
 ON ONLY omg.policy_party_role USING BTREE (agreement_indentifier pg_catalog.int4_ops ASC NULLS LAST) ;

CREATE UNIQUE INDEX IF NOT EXISTS policy_party_role_pkey
 ON ONLY omg.policy_party_role USING BTREE (policy_identifier pg_catalog.int4_ops ASC NULLS LAST, party_role_code COLLATE pg_catalog."default" pg_catalog.text_ops ASC NULLS LAST, begin_date pg_catalog.timestamp_ops ASC NULLS LAST, party_identifier pg_catalog.int8_ops ASC NULLS LAST) ;