
CREATE TABLE public.movies
(
    id bigserial NOT NULL,
    name character varying NOT NULL,
    rating int NOT NULL,
    genre character varying NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS public.movies
    OWNER to postgres;