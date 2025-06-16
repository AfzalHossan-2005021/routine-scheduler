CREATE TABLE public."admin" (
	username varchar NOT NULL,
	email varchar NOT NULL,
	"password" varchar NOT NULL,
	CONSTRAINT admin_pk PRIMARY KEY (username),
	CONSTRAINT admin_un UNIQUE (email)
);

CREATE TABLE public.configs (
	"key" varchar NOT NULL,
	value varchar NOT NULL,
	CONSTRAINT configs_pk PRIMARY KEY (key)
);

CREATE TABLE public.courses (
	course_id varchar NOT NULL,
	"name" varchar NOT NULL,
	"type" int4 NOT NULL,
	"session" varchar NOT NULL,
	class_per_week float8 NOT NULL,
	"from" character varying DEFAULT 'CSE'::character varying NOT NULL,
    "to" character varying DEFAULT 'CSE'::character varying NOT NULL,
    teacher_credit double precision DEFAULT '9'::double precision NOT NULL,
    level_term character varying DEFAULT ''::character varying,
	CONSTRAINT courses_pk PRIMARY KEY (course_id, session)
);

CREATE TABLE public.forms (
	id varchar NOT NULL,
	"type" varchar NOT NULL,
	response varchar NULL,
	initial varchar NOT NULL,
	CONSTRAINT forms_pk PRIMARY KEY (id)
);
CREATE INDEX forms_key_idx ON public.forms USING btree (id);

CREATE TABLE public.lab_room_assignment (
	course_id varchar NOT NULL,
	"session" varchar NOT NULL,
	batch int4 NOT NULL,
	"section" varchar NOT NULL,
	room varchar NULL,
	CONSTRAINT lab_room_assignment_pk PRIMARY KEY (course_id, session, batch, section)
);

CREATE TABLE public.rooms (
	room varchar NOT NULL,
	"type" int4 NULL,
    active boolean DEFAULT true NOT NULL,
	CONSTRAINT rooms_pk PRIMARY KEY (room)
);

CREATE TABLE public.teachers (
	initial varchar NOT NULL,
	"name" varchar NOT NULL,
	surname varchar NOT NULL,
	email varchar NOT NULL,
	seniority_rank int4 NOT NULL,
	active int2 NOT NULL,
	theory_courses int4 NOT NULL,
	sessional_courses int4 NOT NULL,
	designation character varying DEFAULT 'Professor'::character varying NOT NULL,
    full_time_status boolean DEFAULT true NOT NULL,
    offers_thesis_1 boolean DEFAULT true NOT NULL,
    offers_thesis_2 boolean DEFAULT true NOT NULL,
    offers_msc boolean DEFAULT true NOT NULL,
    teacher_credits_offered double precision DEFAULT '15'::double precision NOT NULL,
	CONSTRAINT teachers_pk PRIMARY KEY (initial)
);

CREATE TABLE public.level_term_unique (
    level_term character varying NOT NULL,
    department character varying NOT NULL,
    active boolean DEFAULT false NOT NULL,
    batch integer DEFAULT 0,
	CONSTRAINT level_term_unique_pkey PRIMARY KEY (level_term, department)
);

CREATE TABLE public.sections (
	batch int4 NOT NULL,
	"section" varchar NOT NULL,
	"type" int4 NOT NULL,
	room varchar NULL,
	"session" varchar NOT NULL,
	level_term varchar NOT NULL,
	department character varying DEFAULT 'CSE'::character varying NOT NULL,
	CONSTRAINT sections_pk PRIMARY KEY (batch, section),
	CONSTRAINT sections_fk FOREIGN KEY (room) REFERENCES public.rooms(room) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT sections_department_level_term_fkey FOREIGN KEY (department, level_term) REFERENCES public.level_term_unique(department, level_term)
);

CREATE TABLE public.teacher_assignment (
	course_id varchar NOT NULL,
	initial varchar NOT NULL,
	"session" varchar NOT NULL,
	CONSTRAINT teacher_assignment_pk PRIMARY KEY (course_id, initial, session),
	CONSTRAINT teacher_assignment_fk FOREIGN KEY (course_id,"session") REFERENCES public.courses(course_id,"session") ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT teacher_assignment_fk_1 FOREIGN KEY (initial) REFERENCES public.teachers(initial) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE public.courses_sections (
	course_id varchar NOT NULL,
	"session" varchar NOT NULL,
	batch int4 NOT NULL,
	"section" varchar NOT NULL,
	room_no character varying DEFAULT '103'::character varying,
    department character varying DEFAULT 'CSE'::character varying,
	CONSTRAINT courses_sections_pk PRIMARY KEY (course_id, session, batch, section),
	CONSTRAINT courses_sections_fk FOREIGN KEY (batch,"section") REFERENCES public.sections(batch,"section") ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT courses_sections_fk_c FOREIGN KEY (course_id,"session") REFERENCES public.courses(course_id,"session") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE public.schedule_assignment (
	course_id varchar NOT NULL,
	"session" varchar NOT NULL,
	batch int4 NOT NULL,
	"section" varchar NOT NULL,
	"day" varchar NOT NULL,
	"time" int4 NOT NULL,
	department character varying DEFAULT 'CSE'::character varying NOT NULL,
	CONSTRAINT schedule_assignment_check CHECK (((day)::text = ANY (ARRAY[('Saturday'::character varying)::text, ('Sunday'::character varying)::text, ('Monday'::character varying)::text, ('Tuesday'::character varying)::text, ('Wednesday'::character varying)::text]))),
	CONSTRAINT schedule_assignment_pk PRIMARY KEY (session, batch, section, day, "time"),
	CONSTRAINT schedule_assignment_un UNIQUE (course_id, session, batch, section, day, "time"),
	CONSTRAINT schedule_assignment_fk FOREIGN KEY (course_id,"session") REFERENCES public.courses(course_id,"session"),
	CONSTRAINT schedule_assignment_fk1 FOREIGN KEY (batch,"section") REFERENCES public.sections(batch,"section") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE public.teacher_sessional_assignment (
	initial varchar NOT NULL,
	course_id varchar NOT NULL,
	"session" varchar NOT NULL,
	batch int4 NOT NULL,
	"section" varchar NOT NULL,
	CONSTRAINT teacher_sessional_assignment_pk PRIMARY KEY (initial, course_id, session, batch, section),
	CONSTRAINT teacher_sessional_assignment_courses_sections_fk FOREIGN KEY (course_id,"session",batch,"section") REFERENCES public.courses_sections(course_id,"session",batch,"section"),
	CONSTRAINT teacher_sessional_assignment_teachers_fk FOREIGN KEY (initial) REFERENCES public.teachers(initial)
);

CREATE TABLE public.all_courses (
	course_id varchar NOT NULL,
	"name" varchar NOT NULL,
	"type" int4 NOT NULL,
	class_per_week float8 NOT NULL,
  	"from" varchar NOT NULL,
  	"to" varchar NOT NULL,
  	level_term varchar NOT NULL,
	CONSTRAINT all_courses_pk PRIMARY KEY (course_id, level_term)
);

CREATE TABLE public.departmental_level_term (
    level_term_section character varying NOT NULL,
    full_name character varying,
    level_term character varying,
    department character varying,
	CONSTRAINT departmental_level_term_pkey PRIMARY KEY (level_term_section),
	CONSTRAINT departmental_level_term_level_term_department_fkey FOREIGN KEY (level_term, department) REFERENCES public.level_term_unique(level_term, department)
);

INSERT INTO public."admin" (username,email,"password") VALUES
	('admin','ask@mail.com','$2a$12$9DOeaW4x5gJqWC4WKXMInOzkJUDqbA2x60QhydtAOE81W7qs8Ymqm');
INSERT INTO public.configs ("key",value) VALUES
	('demo','hi this is a template body'),
	('CURRENT_SESSION','Jan-23'),
	('ALL_SESSIONS','["Jan-23"]'),
	('THEORY_PREFERENCES_COMPLETE','0'),
	('THEORY_EMAIL','Sample theory email'),
	('SCHEDULE_EMAIL','Sample schedule email'),
	('SESSIONAL_EMAIL','Sample sessional email');
INSERT INTO public.courses (course_id,"name","type","session",class_per_week) VALUES
	('CHEM113','Chemistry',0,'Jan-23',3.0),
	('CHEM118','Chemistry Sessional',1,'Jan-23',1.0),
	('CSE105','Data Structures and Algorithms I',0,'Jan-23',3.0),
	('CSE106','Data Structures and Algorithms I Sessional',1,'Jan-23',1.0),
	('CSE107','Object Oriented Programming Language',0,'Jan-23',3.0),
	('CSE108','Object Oriented Programming Language Sessional',1,'Jan-23',1.0),
	('CSE207','Data Structures and Algorithms II',0,'Jan-23',3.0),
	('CSE208','Data Structures and Algorithms II Sessional',1,'Jan-23',1.0),
	('CSE211','Theory of Computation',0,'Jan-23',3.0),
	('CSE215','Database',0,'Jan-23',3.0);
INSERT INTO public.courses (course_id,"name","type","session",class_per_week) VALUES
	('CSE216','Database Sessional',1,'Jan-23',1.0),
	('CSE283','Digital Techniques',0,'Jan-23',3.0),
	('CSE284','Digital Techniques Sessional',1,'Jan-23',1.0),
	('CSE301','Mathematical Analysis for Computer Science',0,'Jan-23',3.0),
	('CSE313','Operating System',0,'Jan-23',3.0),
	('CSE314','Operating System Sessional',1,'Jan-23',1.0),
	('CSE317','Artificial Intelligence',0,'Jan-23',3.0),
	('CSE318','Artificial Intelligence Sessional',1,'Jan-23',1.0),
	('CSE321','Computer Networks',0,'Jan-23',3.0),
	('CSE322','Computer Networks Sessional',1,'Jan-23',1.0);
INSERT INTO public.courses (course_id,"name","type","session",class_per_week) VALUES
	('CSE325','Information System Design',0,'Jan-23',3.0),
	('CSE326','Information System Design Sessional',1,'Jan-23',1.0),
	('CSE400','Project and Thesis',1,'Jan-23',1.0),
	('CSE405','Computer Security',0,'Jan-23',3.0),
	('CSE406','Computer Security Sessional',1,'Jan-23',1.0),
	('CSE408','Software Development Sessional',1,'Jan-23',1.0),
	('CSE409','Computer Graphics',0,'Jan-23',3.0),
	('CSE410','Computer Graphics Sessional',1,'Jan-23',1.0),
	('CSE421','Basic Graph Theory',0,'Jan-23',3.0),
	('CSE423','Fault Tolerant Systems',0,'Jan-23',3.0);
INSERT INTO public.courses (course_id,"name","type","session",class_per_week) VALUES
	('CSE463','Introduction to Bioinformatics',0,'Jan-23',3.0),
	('EEE269','Electrical Drives and Instrumentation',0,'Jan-23',3.0),
	('EEE270','Electrical Drives and Instrumentation Sessional',1,'Jan-23',1.0),
	('HUM475','Engineering Economics',0,'Jan-23',3.0),
	('MATH143','Linear Algebra',0,'Jan-23',3.0),
	('MATH247','Linear Algebra, Laplace Transformation and Fourier Analysis',0,'Jan-23',3.0),
	('ME165','Basic Mechanical Engineering',0,'Jan-23',3.0),
	('ME174','Mechanical Engineering Drawing and CAD',1,'Jan-23',1.0),
	('CT','Class Test',0,'Jan-23',3.0);
INSERT INTO public.rooms (room,"type") VALUES
	('MCL',1),
	('MML',1),
	('CL',1),
	('SEL',1),
	('NL',1),
	('IL',1),
	('DL',1),
	('PL',1),
	('BL',1),
	('DBL',1);
INSERT INTO public.rooms (room,"type") VALUES
	('WNL',1),
	('VDAL',1),
	('AIRL',1),
	('IAC',1),
	('103',0),
	('104',0),
	('107',0),
	('108',0),
	('109',0),
	('203',0);
INSERT INTO public.rooms (room,"type") VALUES
	('204',0),
	('205',0),
	('206',0),
	('207',0),
	('903',0),
	('504',0);
INSERT INTO public.level_term_unique (level_term, department) VALUES
	('L-2 T-1',	'BME'),
	('L-2 T-2',	'BME'),
	('L-3 T-1',	'BME'),
	('L-4 T-1',	'BME'),
	('L-1 T-1',	'CSE'),
	('L-1 T-2',	'CSE'),
	('L-2 T-1',	'CSE'),
	('L-2 T-2',	'CSE'),
	('L-3 T-1',	'CSE'),
	('L-3 T-2',	'CSE'),
	('L-4 T-1',	'CSE'),
	('L-4 T-2',	'CSE'),
	('L-1 T-1',	'EEE'),
	('L-4 T-1',	'EEE'),
	('L-2 T-1',	'IPE'),
	('L-2 T-1',	'MME'),
	('L-2 T-1',	'NCE'),
	('L-1 T-2',	'URP');
INSERT INTO public.sections (batch,"section","type",room,"session",level_term) VALUES
	(18,'A',0,'203','Jan-23','L-4 T-1'),
	(18,'B',0,'204','Jan-23','L-4 T-1'),
	(18,'A1',1,NULL,'Jan-23','L-4 T-1'),
	(18,'A2',1,NULL,'Jan-23','L-4 T-1'),
	(18,'B1',1,NULL,'Jan-23','L-4 T-1'),
	(18,'B2',1,NULL,'Jan-23','L-4 T-1'),
	(19,'A',0,'205','Jan-23','L-3 T-2'),
	(19,'B',0,'206','Jan-23','L-3 T-2'),
	(19,'A1',1,NULL,'Jan-23','L-3 T-2'),
	(19,'A2',1,NULL,'Jan-23','L-3 T-2');
INSERT INTO public.sections (batch,"section","type",room,"session",level_term) VALUES
	(19,'B1',1,NULL,'Jan-23','L-3 T-2'),
	(19,'B2',1,NULL,'Jan-23','L-3 T-2'),
	(20,'A',0,'103','Jan-23','L-2 T-2'),
	(20,'B',0,'104','Jan-23','L-2 T-2'),
	(20,'A1',1,NULL,'Jan-23','L-2 T-2'),
	(20,'A2',1,NULL,'Jan-23','L-2 T-2'),
	(20,'B1',1,NULL,'Jan-23','L-2 T-2'),
	(20,'B2',1,NULL,'Jan-23','L-2 T-2'),
	(21,'A',0,'107','Jan-23','L-1 T-2'),
	(21,'B',0,'108','Jan-23','L-1 T-2');
INSERT INTO public.sections (batch,"section","type",room,"session",level_term) VALUES
	(21,'C',0,'109','Jan-23','L-1 T-2'),
	(21,'A1',1,NULL,'Jan-23','L-1 T-2'),
	(21,'A2',1,NULL,'Jan-23','L-1 T-2'),
	(21,'B1',1,NULL,'Jan-23','L-1 T-2'),
	(21,'B2',1,NULL,'Jan-23','L-1 T-2'),
	(21,'C1',1,NULL,'Jan-23','L-1 T-2'),
	(21,'C2',1,NULL,'Jan-23','L-1 T-2');
INSERT INTO public.teachers (initial,"name",surname,email,seniority_rank,active,theory_courses,sessional_courses) VALUES
	('MMA','Dr. Muhammad Masroor Ali','Masroor','routine.scheduler.buet@gmail.com',1,1,1,1),
	('MSR','Dr. Md. Saidur Rahman','Saidur','routine.scheduler.buet@gmail.com',2,0,1,1),
	('MMI','Dr. Md. Monirul Islam','Monir','routine.scheduler.buet@gmail.com',3,0,1,1),
	('MSRJ','Dr. M. Sohel Rahman','Sohel','routine.scheduler.buet@gmail.com',5,0,1,1),
	('AKMAR','Dr. A.K.M. Ashikur Rahman','Ashik','routine.scheduler.buet@gmail.com',6,1,1,1),
	('MEA','Dr. Mohammed Eunus Ali','Eunus','routine.scheduler.buet@gmail.com',7,0,1,1),
	('MN','Dr. Mahmuda Naznin','Mahmuda','routine.scheduler.buet@gmail.com',8,0,1,1),
	('MDMI','Dr. Md. Monirul Islam','Monir Jr.','routine.scheduler.buet@gmail.com',9,0,1,1),
	('TH','Dr. Tanzima Hashem','Tanzima','routine.scheduler.buet@gmail.com',10,0,1,1),
	('MSH','Dr. Md. Shohrab Hossain','Shohrab','routine.scheduler.buet@gmail.com',11,0,1,1);
INSERT INTO public.teachers (initial,"name",surname,email,seniority_rank,active,theory_courses,sessional_courses) VALUES
	('AI','Dr. Anindya Iqbal','Anindya','routine.scheduler.buet@gmail.com',13,1,1,1),
	('RS','Dr. Rifat Shahriyar','Rifat','routine.scheduler.buet@gmail.com',14,0,1,1),
	('MDAA','Dr. Muhammad Abdullah Adnan','Adnan','routine.scheduler.buet@gmail.com',15,0,1,1),
	('MDSR','Dr. Mohammad Saifur Rahman','Saifur','routine.scheduler.buet@gmail.com',16,0,1,1),
	('MSB','Dr. Md. Shamsuzzoha Bayzid','Bayzid','routine.scheduler.buet@gmail.com',17,0,1,1),
	('AHR','Dr. Atif Hasan Rahman','Atif','routine.scheduler.buet@gmail.com',18,1,1,1),
	('SS','Dr. Sadia Sharmin','Sadia','routine.scheduler.buet@gmail.com',19,0,1,1),
	('AW','Abu Wasif','Wasif','routine.scheduler.buet@gmail.com',20,0,1,1),
	('TA','Tanveer Awal','Tanveer','routine.scheduler.buet@gmail.com',21,0,1,1),
	('KMS','Khaled Mahmud Shahriar','Shahriar','routine.scheduler.buet@gmail.com',22,0,1,1);
INSERT INTO public.teachers (initial,"name",surname,email,seniority_rank,active,theory_courses,sessional_courses) VALUES
	('MSIB','Md. Shariful Islam Bhuyan','Sharif','routine.scheduler.buet@gmail.com',23,1,1,1),
	('SB','Sukarna Barua','Sukarna','routine.scheduler.buet@gmail.com',24,0,1,1),
	('MAN','Dr. Muhammad Ali Nayeem','Nayeem','routine.scheduler.buet@gmail.com',25,0,1,1),
	('RRR','Dr. Rezwana Reaz Rimpi','Rezwana','routine.scheduler.buet@gmail.com',26,0,1,1),
	('HT','Tahmid Hasan','Tahmid','routine.scheduler.buet@gmail.com',27,0,1,1),
	('TM','Md. Tareq Mahmood','Tareq','routine.scheduler.buet@gmail.com',28,1,1,1),
	('PSA','Preetom Saha Arko','Arko','routine.scheduler.buet@gmail.com',29,0,1,1),
	('RRD','Rayhan Rashed','Rayhan','routine.scheduler.buet@gmail.com',32,0,1,1),
	('MTH','Mohammad Tawhidul Hasan Bhuiyan','Tuhin','routine.scheduler.buet@gmail.com',33,0,1,1),
	('NBH','Navid Bin Hasan','Navid','routine.scheduler.buet@gmail.com',34,0,1,1);
INSERT INTO public.teachers (initial,"name",surname,email,seniority_rank,active,theory_courses,sessional_courses) VALUES
	('MAI','Md. Ashraful Islam','Ashraful','routine.scheduler.buet@gmail.com',35,1,1,1),
	('MHE','A. K. M. Mehedi Hasan','Mehedi','routine.scheduler.buet@gmail.com',36,0,1,1),
	('ART','Abdur Rashid Tushar','Tushar','routine.scheduler.buet@gmail.com',37,0,1,1),
	('IJ','Ishrat Jahan','Ishrat','routine.scheduler.buet@gmail.com',38,0,1,1),
	('MRI','Md. Ruhan Islam','Ruhan','routine.scheduler.buet@gmail.com',39,0,1,1),
	('SAH','Sheikh Azizul Hakim','Hakim','routine.scheduler.buet@gmail.com',40,1,1,1),
	('KRV','Kowshic Roy','Vodro','routine.scheduler.buet@gmail.com',41,0,1,1),
	('MTM','Mashiat Mustaq','Mashiat','routine.scheduler.buet@gmail.com',42,0,1,1),
	('SMH','Saem Hasan','Saem','routine.scheduler.buet@gmail.com',43,0,1,1),
	('KMRH','Khandokar Md. Rahat Hossain','Rahat','routine.scheduler.buet@gmail.com',44,0,1,1);
INSERT INTO public.teachers (initial,"name",surname,email,seniority_rank,active,theory_courses,sessional_courses) VALUES
	('AAI','Dr. A. B. M. Alim Al Islam','Alim','routine.scheduler.buet@gmail.com',12,0,1,1),
	('MMAK','Dr. Md. Mostofa Akbar','Mostofa','routine.scheduler.buet@gmail.com',4,0,1,1),
	('MTZ','Md. Toufikuzzaman','Toufik','routine.scheduler.buet@gmail.com',31,1,1,1);
INSERT INTO public.courses_sections (course_id,"session",batch,"section") VALUES
	('CHEM113','Jan-23',21,'A'),
	('CHEM113','Jan-23',21,'B'),
	('CHEM113','Jan-23',21,'C'),
	('CHEM118','Jan-23',21,'A1'),
	('CHEM118','Jan-23',21,'A2'),
	('CHEM118','Jan-23',21,'B1'),
	('CHEM118','Jan-23',21,'B2'),
	('CHEM118','Jan-23',21,'C1'),
	('CHEM118','Jan-23',21,'C2'),
	('CSE105','Jan-23',21,'A');
INSERT INTO public.courses_sections (course_id,"session",batch,"section") VALUES
	('CSE105','Jan-23',21,'B'),
	('CSE105','Jan-23',21,'C'),
	('CSE106','Jan-23',21,'A1'),
	('CSE106','Jan-23',21,'A2'),
	('CSE106','Jan-23',21,'B1'),
	('CSE106','Jan-23',21,'B2'),
	('CSE106','Jan-23',21,'C1'),
	('CSE106','Jan-23',21,'C2'),
	('CSE107','Jan-23',21,'A'),
	('CSE107','Jan-23',21,'B');
INSERT INTO public.courses_sections (course_id,"session",batch,"section") VALUES
	('CSE107','Jan-23',21,'C'),
	('CSE108','Jan-23',21,'A1'),
	('CSE108','Jan-23',21,'A2'),
	('CSE108','Jan-23',21,'B1'),
	('CSE108','Jan-23',21,'B2'),
	('CSE108','Jan-23',21,'C1'),
	('CSE108','Jan-23',21,'C2'),
	('CSE207','Jan-23',20,'A'),
	('CSE207','Jan-23',20,'B'),
	('CSE208','Jan-23',20,'A1');
INSERT INTO public.courses_sections (course_id,"session",batch,"section") VALUES
	('CSE208','Jan-23',20,'A2'),
	('CSE208','Jan-23',20,'B1'),
	('CSE208','Jan-23',20,'B2'),
	('CSE211','Jan-23',20,'A'),
	('CSE211','Jan-23',20,'B'),
	('CSE215','Jan-23',20,'A'),
	('CSE215','Jan-23',20,'B'),
	('CSE216','Jan-23',20,'A1'),
	('CSE216','Jan-23',20,'A2'),
	('CSE216','Jan-23',20,'B1');
INSERT INTO public.courses_sections (course_id,"session",batch,"section") VALUES
	('CSE216','Jan-23',20,'B2'),
	('CSE283','Jan-23',20,'A'),
	('CSE283','Jan-23',20,'B'),
	('CSE284','Jan-23',20,'A1'),
	('CSE284','Jan-23',20,'A2'),
	('CSE284','Jan-23',20,'B1'),
	('CSE284','Jan-23',20,'B2'),
	('CSE301','Jan-23',19,'A'),
	('CSE301','Jan-23',19,'B'),
	('CSE313','Jan-23',19,'A');
INSERT INTO public.courses_sections (course_id,"session",batch,"section") VALUES
	('CSE313','Jan-23',19,'B'),
	('CSE314','Jan-23',19,'A1'),
	('CSE314','Jan-23',19,'A2'),
	('CSE314','Jan-23',19,'B1'),
	('CSE314','Jan-23',19,'B2'),
	('CSE317','Jan-23',19,'A'),
	('CSE317','Jan-23',19,'B'),
	('CSE318','Jan-23',19,'A1'),
	('CSE318','Jan-23',19,'A2'),
	('CSE318','Jan-23',19,'B1');
INSERT INTO public.courses_sections (course_id,"session",batch,"section") VALUES
	('CSE318','Jan-23',19,'B2'),
	('CSE321','Jan-23',19,'A'),
	('CSE321','Jan-23',19,'B'),
	('CSE322','Jan-23',19,'A1'),
	('CSE322','Jan-23',19,'A2'),
	('CSE322','Jan-23',19,'B1'),
	('CSE322','Jan-23',19,'B2'),
	('CSE325','Jan-23',19,'A'),
	('CSE325','Jan-23',19,'B'),
	('CSE326','Jan-23',19,'A1');
INSERT INTO public.courses_sections (course_id,"session",batch,"section") VALUES
	('CSE326','Jan-23',19,'A2'),
	('CSE326','Jan-23',19,'B1'),
	('CSE326','Jan-23',19,'B2'),
	('CSE400','Jan-23',18,'A1'),
	('CSE400','Jan-23',18,'A2'),
	('CSE400','Jan-23',18,'B1'),
	('CSE400','Jan-23',18,'B2'),
	('CSE405','Jan-23',18,'A'),
	('CSE405','Jan-23',18,'B'),
	('CSE406','Jan-23',18,'A1');
INSERT INTO public.courses_sections (course_id,"session",batch,"section") VALUES
	('CSE406','Jan-23',18,'A2'),
	('CSE406','Jan-23',18,'B1'),
	('CSE406','Jan-23',18,'B2'),
	('CSE408','Jan-23',18,'A1'),
	('CSE408','Jan-23',18,'A2'),
	('CSE408','Jan-23',18,'B1'),
	('CSE408','Jan-23',18,'B2'),
	('CSE409','Jan-23',18,'A'),
	('CSE409','Jan-23',18,'B'),
	('CSE410','Jan-23',18,'A1');
INSERT INTO public.courses_sections (course_id,"session",batch,"section") VALUES
	('CSE410','Jan-23',18,'A2'),
	('CSE410','Jan-23',18,'B1'),
	('CSE410','Jan-23',18,'B2'),
	('CSE421','Jan-23',18,'A'),
	('CSE463','Jan-23',18,'A'),
	('CSE463','Jan-23',18,'B'),
	('EEE269','Jan-23',20,'A'),
	('EEE269','Jan-23',20,'B'),
	('EEE270','Jan-23',20,'A1'),
	('EEE270','Jan-23',20,'A2');
INSERT INTO public.courses_sections (course_id,"session",batch,"section") VALUES
	('EEE270','Jan-23',20,'B1'),
	('EEE270','Jan-23',20,'B2'),
	('HUM475','Jan-23',18,'A'),
	('HUM475','Jan-23',18,'B'),
	('MATH143','Jan-23',21,'A'),
	('MATH143','Jan-23',21,'B'),
	('MATH143','Jan-23',21,'C'),
	('MATH247','Jan-23',20,'A'),
	('MATH247','Jan-23',20,'B'),
	('ME165','Jan-23',21,'A');
INSERT INTO public.courses_sections (course_id,"session",batch,"section") VALUES
	('ME165','Jan-23',21,'B'),
	('ME165','Jan-23',21,'C'),
	('ME174','Jan-23',21,'A1'),
	('ME174','Jan-23',21,'A2'),
	('ME174','Jan-23',21,'B1'),
	('ME174','Jan-23',21,'B2'),
	('ME174','Jan-23',21,'C1'),
	('ME174','Jan-23',21,'C2'),
	('CSE423','Jan-23',18,'B');

INSERT INTO all_courses (course_id, name, type, class_per_week, "from", "to", level_term) VALUES
	-- Level 1, Term 1 Courses
	('CSE101', 'Structured Programming Language', 0, 3.00, 'CSE', 'CSE', 'L-1 T-1'),
	('CSE102', 'Structured Programming Language Sessional', 1, 1.00, 'CSE', 'CSE', 'L-1 T-1'),
	('CSE103', 'Discrete Mathematics', 0, 3.00, 'CSE', 'CSE', 'L-1 T-1'),
	('EEE163', 'Introduction to Electrical Engineering', 0, 3.00, 'EEE', 'CSE', 'L-1 T-1'),
	('EEE164', 'Introduction to Electrical Engineering Sessional', 1, 1.00, 'EEE', 'CSE', 'L-1 T-1'),
	('MATH141', 'Calculus I', 0, 3.00, 'MATH', 'CSE', 'L-1 T-1'),
	('PHY129', 'Structure of Matter, Electricity & Magnetism, Wave Mechanics', 0, 3.00, 'PHY', 'CSE', 'L-1 T-1'),
	('PHY114', 'Physics Sessional', 1, 1.00, 'PHY', 'CSE', 'L-1 T-1'),

	-- Level 1, Term 2 Courses
	('CSE107', 'Object Oriented Programming Language', 0, 3.00, 'CSE', 'CSE', 'L-1 T-2'),
	('CSE108', 'Object Oriented Programming Language Sessional', 1, 1.00, 'CSE', 'CSE', 'L-1 T-2'),
	('CSE105', 'Data Structures and Algorithms I', 0, 3.00, 'CSE', 'CSE', 'L-1 T-2'),
	('CSE106', 'Data Structures and Algorithms I Sessional', 1, 1.00, 'CSE', 'CSE', 'L-1 T-2'),
	('CHEM113', 'Chemistry', 0, 3.00, 'CHEM', 'CSE', 'L-1 T-2'),
	('CHEM118', 'Chemistry Sessional', 1, 1.00, 'CHEM', 'CSE', 'L-1 T-2'),
	('MATH143', 'Linear Algebra', 0, 3.00, 'MATH', 'CSE', 'L-1 T-2'),
	('ME165', 'Basic Mechanical Engineering', 0, 3.00, 'ME', 'CSE', 'L-1 T-2'),
	('ME174', 'Mechanical Engineering Drawing and CAD', 1, 1.00, 'ME', 'CSE', 'L-1 T-2'),

	-- Level 2, Term 1 Courses
	('CSE205', 'Digital Logic Design', 0, 3.00, 'CSE', 'CSE', 'L-2 T-1'),
	('CSE206', 'Digital Logic Design Sessional', 1, 1.00, 'CSE', 'CSE', 'L-2 T-1'),
	('CSE207', 'Data Structures and Algorithms II', 0, 3.00, 'CSE', 'CSE', 'L-2 T-1'),
	('CSE208', 'Data Structures and Algorithms II Sessional', 1, 1.00, 'CSE', 'CSE', 'L-2 T-1'),
	('CSE215', 'Database', 0, 3.00, 'CSE', 'CSE', 'L-2 T-1'),
	('CSE216', 'Database Sessional', 1, 1.00, 'CSE', 'CSE', 'L-2 T-1'),
	('EEE263', 'Electronic Circuits', 0, 3.00, 'EEE', 'CSE', 'L-2 T-1'),
	('EEE264', 'Electronic Circuits Sessional', 1, 1.00, 'EEE', 'CSE', 'L-2 T-1'),
	('MATH241', 'Advanced Calculus', 0, 3.00, 'MATH', 'CSE', 'L-2 T-1'),

	-- Level 2, Term 2 Courses
	('CSE200', 'Technical Writing and Presentation', 0, 0.75, 'CSE', 'CSE', 'L-2 T-2'),
	('CSE209', 'Computer Architecture', 0, 3.00, 'CSE', 'CSE', 'L-2 T-2'),
	('CSE210', 'Computer Architecture Sessional', 1, 1.00, 'CSE', 'CSE', 'L-2 T-2'),
	('CSE211', 'Theory of Computation', 0, 3.00, 'CSE', 'CSE', 'L-2 T-2'),
	('CSE213', 'Software Engineering', 0, 3.00, 'CSE', 'CSE', 'L-2 T-2'),
	('CSE214', 'Software Engineering Sessional', 1, 1.00, 'CSE', 'CSE', 'L-2 T-2'),
	('CSE219', 'Signals and Linear Systems', 0, 3.00, 'CSE', 'CSE', 'L-2 T-2'),
	('CSE220', 'Signals and Linear Systems Sessional', 1, 1.00, 'CSE', 'CSE', 'L-2 T-2'),
	('MATH243', 'Probability and Statistics', 0, 3.00, 'MATH', 'CSE', 'L-2 T-2'),

	-- Level 3, Term 1 Courses
	('CSE301', 'Mathematics for Computing and Data Science', 0, 3.00, 'CSE', 'CSE', 'L-3 T-1'),
	('CSE309', 'Compiler', 0, 3.00, 'CSE', 'CSE', 'L-3 T-1'),
	('CSE310', 'Compiler Sessional', 1, 1.00, 'CSE', 'CSE', 'L-3 T-1'),
	('CSE313', 'Operating System', 0, 3.00, 'CSE', 'CSE', 'L-3 T-1'),
	('CSE314', 'Operating System Sessional', 1, 1.00, 'CSE', 'CSE', 'L-3 T-1'),
	('CSE315', 'Microprocessors, Microcontrollers, and Embedded Systems', 0, 3.00, 'CSE', 'CSE', 'L-3 T-1'),
	('CSE316', 'Microprocessors, Microcontrollers, and Embedded Systems Sessional', 1, 1.00, 'CSE', 'CSE', 'L-3 T-1'),
	('CSE317', 'Artificial Intelligence', 0, 3.00, 'CSE', 'CSE', 'L-3 T-1'),
	('CSE318', 'Artificial Intelligence Sessional', 1, 1.00, 'CSE', 'CSE', 'L-3 T-1'),

	-- Level 3, Term 2 Courses
	('CSE311', 'Data Communication', 0, 3.00, 'CSE', 'CSE', 'L-3 T-2'),
	('CSE321', 'Computer Networks', 0, 3.00, 'CSE', 'CSE', 'L-3 T-2'),
	('CSE322', 'Computer Networks Sessional', 1, 1.00, 'CSE', 'CSE', 'L-3 T-2'),
	('CSE325', 'Information Systems Development and Management', 0, 3.00, 'CSE', 'CSE', 'L-3 T-2'),
	('CSE326', 'Information Systems Development and Management Sessional', 1, 1.00, 'CSE', 'CSE', 'L-3 T-2'),
	('CSE329', 'Machine Learning', 0, 3.00, 'CSE', 'CSE', 'L-3 T-2'),
	('CSE330', 'Machine Learning Sessional', 1, 1.00, 'CSE', 'CSE', 'L-3 T-2'),
	-- ('CSE450', 'Capstone Project', 0, 1.50, 'CSE', 'CSE', 'L-3 T-2'),
	('HUM347', 'Ethics in Society and E-Governance', 0, 3.00, 'HUM', 'CSE', 'L-3 T-2'),

	-- Level 4, Term 1 Courses
	('CSE400', 'Project and Thesis', 0, 3.00, 'CSE', 'CSE', 'L-4 T-1'),
	('CSE401', 'Numerical Analysis, Simulation and Modeling', 0, 3.00, 'CSE', 'CSE', 'L-4 T-1'),
	('CSE402', 'Numerical Analysis, Simulation and Modeling Sessional', 1, 1.00, 'CSE', 'CSE', 'L-4 T-1'),
	('CSE405', 'Cyber Security', 0, 3.00, 'CSE', 'CSE', 'L-4 T-1'),
	('CSE406', 'Cyber Security Sessional', 1, 1.00, 'CSE', 'CSE', 'L-4 T-1'),
	('CSE450', 'Capstone Project', 0, 1.50, 'CSE', 'CSE', 'L-4 T-1'),
	('HUM475', 'Engineering Economics', 0, 3.00, 'HUM', 'CSE', 'L-4 T-1'),

	-- Level 4, Term 2 Courses
	('CSE400', 'Project and Thesis', 0, 3.00, 'CSE', 'CSE', 'L-4 T-2'),
	('IPE493', 'Industrial Management', 0, 3.00, 'IPE', 'CSE', 'L-4 T-2'),
	('HUM402', 'Professional Communication in English Sessional', 1, 1.00, 'HUM', 'CSE', 'L-4 T-2'),
	('HUM403', 'Communication in English', 0, 3.00, 'HUM', 'CSE', 'L-4 T-2'),
	('HUM429', 'Accounting and Entrepreneurship for IT Business', 0, 3.00, 'HUM', 'CSE', 'L-4 T-2'),

	-- Elective Courses from Level 4
	('CSE417', 'Cyber-Physical Systems', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('CSE419', 'Internet of Things (IoT)', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('CSE421', 'Basic Graph Theory', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('CSE423', 'Fault Tolerant Systems', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('CSE425', 'Human Computer Interaction', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('CSE429', 'Deep Learning', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('CSE435', 'Introduction to Quantum Computing', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('CSE441', 'Mobile Computing', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('CSE445', 'Data Mining and Information Retrieval', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('CSE453', 'High Performance Database System', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('CSE455', 'Next Generation Wireless Networks', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('CSE457', 'Wireless Networks', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('CSE459', 'Communication Systems', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('CSE463', 'Bioinformatics', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('CSE467', 'Software Architecture', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('CSE477', 'Cloud Computing', 0, 3.00, 'CSE', 'CSE', 'L-4 Elective'),
	('EEE463', 'Optical Communications', 0, 3.00, 'EEE', 'CSE', 'L-4 Elective'),
	('EEE465', 'Telecommunication Systems', 0, 3.00, 'EEE', 'CSE', 'L-4 Elective'),
	('MATH441', 'Mathematical Optimization', 0, 3.00, 'MATH', 'CSE', 'L-4 Elective'),
	('MATH443', 'Game Theory', 0, 3.00, 'MATH', 'CSE', 'L-4 Elective'),
	('PHY405', 'Quantum Mechanics', 0, 3.00, 'PHY', 'CSE', 'L-4 Elective'),

	-- Non-departmentals from CSE
	('CSE109', 'CSE109', 0, 3.00, 'CSE', 'EEE', 'L-1 T-1'),
	('CSE110', 'CSE110', 1, 1, 'CSE', 'EEE', 'L-1 T-1'),
	('CSE283', 'CSE283', 0, 3.00, 'CSE', 'BME', 'L-2 T-2'),
	('CSE284', 'CSE284', 1, 1, 'CSE', 'BME', 'L-2 T-2'),
	('CSE295', 'CSE295', 0, 3.00, 'CSE', 'IPE', 'L-2 T-1'),
	('CSE287', 'CSE287', 0, 3.00, 'CSE', 'MME', 'L-2 T-1'),
	('CSE451', 'CSE451', 0, 3.00, 'CSE', 'EEE', 'L-4 T-1'),
	('CSE281', 'CSE281', 0, 3.00, 'CSE', 'BME', 'L-2 T-1'),
	('CSE391', 'CSE391', 0, 3.00, 'CSE', 'BME', 'L-3 T-1'),
	('CSE495', 'CSE495', 0, 3.00, 'CSE', 'BME', 'L-4 T-1'),
	('CSE273', 'CSE273', 0, 3.00, 'CSE', 'NCE', 'L-2 T-1'),
	('CSE296', 'CSE296', 1, 1, 'CSE', 'IPE', 'L-2 T-1'),
	('CSE288', 'CSE288', 1, 1, 'CSE', 'MME', 'L-2 T-1'),
	('CSE282', 'CSE282', 1, 1, 'CSE', 'BME', 'L-2 T-1'),
	('CSE392', 'CSE392', 1, 1, 'CSE', 'BME', 'L-3 T-1'),
	('CSE274', 'CSE274', 1, 1, 'CSE', 'NCE', 'L-2 T-1'),
	('CSE170', 'CSE170', 1, 1, 'CSE', 'URP', 'L-1 T-2');
INSERT INTO public.departmental_level_term (level_term_section, full_name, level_term, department) VALUES
	('1/1/A',	'Level 1, Term 1 (Sec A)',	'L-1 T-1',	'CSE'),
	('1/1/B',	'Level 1, Term 1 (Sec B)',	'L-1 T-1',	'CSE'),
	('1/1/C',	'Level 1, Term 1 (Sec C)',	'L-1 T-1',	'CSE'),
	('1/2/A',	'Level 1, Term 2 (Sec A)',	'L-1 T-2',	'CSE'),
	('1/2/B',	'Level 1, Term 2 (Sec B)',	'L-1 T-2',	'CSE'),
	('1/2/C',	'Level 1, Term 2 (Sec C)',	'L-1 T-2',	'CSE'),
	('2/1/A',	'Level 2, Term 1 (Sec A)',	'L-2 T-1',	'CSE'),
	('2/1/B',	'Level 2, Term 1 (Sec B)',	'L-2 T-1',	'CSE'),
	('2/1/C',	'Level 2, Term 1 (Sec C)',	'L-2 T-1',	'CSE'),
	('2/2/A',	'Level 2, Term 2 (Sec A)',	'L-2 T-2',	'CSE'),
	('2/2/B',	'Level 2, Term 2 (Sec B)',	'L-2 T-2',	'CSE'),
	('2/2/C',	'Level 2, Term 2 (Sec C)',	'L-2 T-2',	'CSE'),
	('3/1/A',	'Level 3, Term 1 (Sec A)',	'L-3 T-1',	'CSE'),
	('3/1/B',	'Level 3, Term 1 (Sec B)',	'L-3 T-1',	'CSE'),
	('3/1/C',	'Level 3, Term 1 (Sec C)',	'L-3 T-1',	'CSE'),
	('3/2/A',	'Level 3, Term 2 (Sec A)',	'L-3 T-2',	'CSE'),
	('3/2/B',	'Level 3, Term 2 (Sec B)',	'L-3 T-2',	'CSE'),
	('3/2/C',	'Level 3, Term 2 (Sec C)',	'L-3 T-2',	'CSE'),
	('4/1/A',	'Level 4, Term 1 (Sec A)',	'L-4 T-1',	'CSE'),
	('4/1/B',	'Level 4, Term 1 (Sec B)',	'L-4 T-1',	'CSE'),
	('4/2/A',	'Level 4, Term 2 (Sec A)',	'L-4 T-2',	'CSE'),
	('4/2/B',	'Level 4, Term 2 (Sec B)',	'L-4 T-2',	'CSE'),
	('EEE/1/1',	'Level 1, Term 1',	'L-1 T-1',	'EEE'),
	('EEE/4/1',	'Level 4, Term 1',	'L-4 T-1',	'EEE'),
	('BME/2/1',	'Level 2, Term 1',	'L-2 T-1',	'BME'),
	('BME/2/2',	'Level 2, Term 2',	'L-2 T-2',	'BME'),
	('BME/3/1',	'Level 3, Term 1',	'L-3 T-1',	'BME'),
	('BME/4/1',	'Level 4, Term 1',	'L-4 T-1',	'BME'),
	('MME/2/1',	'Level 2, Term 1',	'L-2 T-1',	'MME'),
	('IPE/2/1',	'Level 2, Term 1',	'L-2 T-1',	'IPE'),
	('URP/1/2',	'Level 1, Term 2',	'L-1 T-2',	'URP'),
	('NCE/2/1',	'Level 2, Term 1',	'L-2 T-1',	'NCE');
INSERT INTO public.forms (id, type, response, initial) VALUES
	('285d70ba-ab8a-43d1-b501-754b7d0ef22d',	'theory-pref',	'"CSE109","CSE101","CSE103"',	'MTM'),
	('eb1caaeb-58a5-4e66-b421-c51979c6dd51',	'theory-pref',	'"CSE103","CSE109","CSE101"',	'IJ'),
	('137662f0-4e7e-4872-84c2-bd41152d8b16',	'theory-pref',	'"CSE101","CSE103","CSE109"',	'KRV'),
	('512093eb-44f2-42b5-bf63-45f40a5b0445',	'theory-pref',	'"CSE101","CSE103","CSE109"',	'SMH'),
	('a2de7d2d-7af3-4429-8c2b-48bd7f9813f8',	'theory-pref',	'"CSE103","CSE101","CSE109"',	'MUS'),
	('2092b23b-044c-43a7-8c13-91227f92bfa9',	'theory-pref',	'"CSE103","CSE101","CSE109"',	'FNW'),
	('e9b2d3d3-b120-49dc-adcf-c97a86cc9076',	'theory-pref',	'"CSE109","CSE101","CSE103"',	'SRK'),
	('2f7c28cf-f165-4c78-88ea-43ab4ab08d96',	'theory-pref',	'"CSE101","CSE103","CSE109"',	'SAH'),
	('d99885ba-6595-4cd3-91cf-f64e0ec9e762',	'theory-sched',	'{"day":"Sunday","time":"10","batch":"21","section":"A"},{"day":"Monday","time":"12","batch":"21","section":"A"},{"day":"Tuesday","time":"11","batch":"21","section":"A"},{"day":"Sunday","time":"9","batch":"21","section":"B"},{"day":"Monday","time":"9","batch":"21","section":"B"},{"day":"Tuesday","time":"12","batch":"21","section":"B"},{"day":"Sunday","time":"12","batch":"21","section":"C"},{"day":"Tuesday","time":"9","batch":"21","section":"C"},{"day":"Monday","time":"11","batch":"21","section":"C"}',	'IJ'),
	('2709a112-3c27-419f-9f84-ed5e20947772',	'theory-sched',	'{"day":"Sunday","time":"9","batch":"21","section":"A"},{"day":"Tuesday","time":"9","batch":"21","section":"A"},{"day":"Wednesday","time":"10","batch":"21","section":"A"},{"day":"Saturday","time":"10","batch":"21","section":"B"},{"day":"Sunday","time":"10","batch":"21","section":"B"},{"day":"Tuesday","time":"10","batch":"21","section":"B"},{"day":"Sunday","time":"10","batch":"21","section":"C"},{"day":"Tuesday","time":"10","batch":"21","section":"C"},{"day":"Wednesday","time":"9","batch":"21","section":"C"}',	'SAH'),
	('2d1a7f54-29da-4655-9904-73f92fa93a3c',	'theory-sched',	'{"day":"Sunday","time":"9","batch":"21","section":"A"},{"day":"Tuesday","time":"9","batch":"21","section":"A"},{"day":"Wednesday","time":"10","batch":"21","section":"A"},{"day":"Saturday","time":"10","batch":"21","section":"B"},{"day":"Sunday","time":"10","batch":"21","section":"B"},{"day":"Tuesday","time":"10","batch":"21","section":"B"},{"day":"Sunday","time":"10","batch":"21","section":"C"},{"day":"Tuesday","time":"10","batch":"21","section":"C"},{"day":"Wednesday","time":"9","batch":"21","section":"C"}',	'KRV'),
	('c23bfc3c-cc0f-41ca-b0b6-2f42c2af03b8',	'theory-sched',	'{"day":"Sunday","time":"9","batch":"21","section":"A"},{"day":"Tuesday","time":"10","batch":"21","section":"A"},{"day":"Wednesday","time":"9","batch":"21","section":"A"},{"day":"Sunday","time":"10","batch":"21","section":"B"},{"day":"Tuesday","time":"9","batch":"21","section":"B"},{"day":"Wednesday","time":"10","batch":"21","section":"B"},{"day":"Saturday","time":"10","batch":"21","section":"C"},{"day":"Sunday","time":"10","batch":"21","section":"C"},{"day":"Wednesday","time":"10","batch":"21","section":"C"}',	'MTM'),
	('ef2216e3-ea6f-4d83-8ce4-8d78c8eb64ef',	'theory-sched',	'{"day":"Sunday","time":"9","batch":"21","section":"A"},{"day":"Tuesday","time":"9","batch":"21","section":"A"},{"day":"Wednesday","time":"10","batch":"21","section":"A"},{"day":"Saturday","time":"10","batch":"21","section":"B"},{"day":"Sunday","time":"10","batch":"21","section":"B"},{"day":"Tuesday","time":"10","batch":"21","section":"B"},{"day":"Sunday","time":"10","batch":"21","section":"C"},{"day":"Tuesday","time":"10","batch":"21","section":"C"},{"day":"Wednesday","time":"9","batch":"21","section":"C"}',	'SMH'),
	('ff98b8f5-f6f4-40bc-9d77-7f03bcf1a872',	'theory-sched',	'{"day":"Sunday","time":"9","batch":"21","section":"A"},{"day":"Tuesday","time":"10","batch":"21","section":"A"},{"day":"Wednesday","time":"9","batch":"21","section":"A"},{"day":"Sunday","time":"10","batch":"21","section":"B"},{"day":"Tuesday","time":"9","batch":"21","section":"B"},{"day":"Wednesday","time":"10","batch":"21","section":"B"},{"day":"Saturday","time":"10","batch":"21","section":"C"},{"day":"Sunday","time":"10","batch":"21","section":"C"},{"day":"Wednesday","time":"10","batch":"21","section":"C"}',	'SRK'),
	('9c0fdd37-ee74-4d32-93aa-6a5b77732bd3',	'theory-sched',	'{"day":"Sunday","time":"10","batch":"21","section":"A"},{"day":"Monday","time":"12","batch":"21","section":"A"},{"day":"Tuesday","time":"11","batch":"21","section":"A"},{"day":"Sunday","time":"9","batch":"21","section":"B"},{"day":"Monday","time":"9","batch":"21","section":"B"},{"day":"Tuesday","time":"12","batch":"21","section":"B"},{"day":"Sunday","time":"12","batch":"21","section":"C"},{"day":"Tuesday","time":"9","batch":"21","section":"C"},{"day":"Monday","time":"11","batch":"21","section":"C"}',	'FNW'),
	('13156d48-75dd-41ea-8278-707e6361b390',	'theory-sched',	'{"day":"Sunday","time":"10","batch":"21","section":"A"},{"day":"Monday","time":"12","batch":"21","section":"A"},{"day":"Tuesday","time":"11","batch":"21","section":"A"},{"day":"Sunday","time":"9","batch":"21","section":"B"},{"day":"Monday","time":"9","batch":"21","section":"B"},{"day":"Tuesday","time":"12","batch":"21","section":"B"},{"day":"Sunday","time":"12","batch":"21","section":"C"},{"day":"Tuesday","time":"9","batch":"21","section":"C"},{"day":"Monday","time":"11","batch":"21","section":"C"}',	'MUS'),
	('b0b63ff4-0b0c-4323-b999-1c2d1affb690',	'sessional-pref',	'"CSE102","CSE110"',	'FNW'),
	('9201328e-1e6a-4ee1-bc7a-39903936406e',	'sessional-pref',	'"CSE110","CSE102"',	'SRK'),
	('5d77d272-ac4e-4a60-8b72-5e094c770039',	'sessional-pref',	'"CSE102","CSE110"',	'SMH'),
	('1e6bc742-225f-47c6-b6f0-6d5f9a08e8c9',	'sessional-pref',	'"CSE102","CSE110"',	'KRV'),
	('57790095-b1bd-41fe-806e-c3f6bd3897ac',	'sessional-pref',	'"CSE110","CSE102"',	'MTM'),
	('7b51df87-1f66-4cd0-8806-62d0417a44a3',	'sessional-pref',	'"CSE102","CSE110"',	'MUS'),
	('8521da6d-3565-42fb-975c-9de35226bbba',	'sessional-pref',	'"CSE102","CSE110"',	'SAH'),
	('003c2d4f-85ba-4c93-9c1e-6dad908bb929',	'sessional-pref',	'"CSE110","CSE102"',	'IJ');
