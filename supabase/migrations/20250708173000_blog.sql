create table authors (
    id uuid primary key references auth.users(id) on delete cascade,
    name text not null,
    bio text,
    created_at timestamp with time zone default now(),
    updated_at timestamp with time zone default now()
);

alter table authors enable row level security;

create policy "Enable read access for all users"
on authors
for select
using (
    auth.uid() = id
);

create policy "Enable insert access for all users"
on authors
for insert
with check (true);

create policy "Enable update access for all users"
on authors
for update
using (
    auth.uid() = id
);

create policy "Enable delete access for all users"
on authors
for delete
using (
    auth.uid() = id
);

-- Function "public.new_user_created_setup"
-- Setup a new user account after user creation
create
    or replace function public.new_user_created_setup() returns trigger
    language plpgsql
    security definer
    set
        search_path = '' as
$$
declare
    user_name text;
begin
    if new.raw_user_meta_data ->> 'name' is not null then
        user_name := new.raw_user_meta_data ->> 'name';

    end if;

    if user_name is null and new.email is not null then
        user_name := split_part(new.email, '@', 1);

    end if;

    if user_name is null then
        user_name := '';

    end if;

    insert into public.authors(id, name)
    values (new.id, user_name);

    return new;

end;

$$;

-- trigger the function every time a user is created
create trigger on_auth_user_created
    after insert
    on auth.users
    for each row
execute procedure public.new_user_created_setup();


create table posts (
    id uuid primary key default gen_random_uuid(),
    author_id uuid not null references authors(id) on delete cascade default auth.uid(),
    title text not null,
    content text not null,
    slug text unique not null,
    is_published boolean default false,
    created_at timestamp with time zone default now(),
    updated_at timestamp with time zone default now()
);

alter table posts enable row level security;

create policy "Enable read access for all users"
on posts
for select
using (true);

create policy "Enable insert access for all users"
on posts
for insert
with check (
    true
);

create policy "Enable update access for all users"
on posts
for update
using (
    auth.uid() = author_id
);

create policy "Enable delete access for all users"
on posts
for delete
using (
    auth.uid() = author_id
);


create table comments (
    id uuid primary key default gen_random_uuid(),
    post_id uuid references posts(id) on delete cascade,
    author_id uuid references authors(id) on delete cascade default auth.uid(),
    content text not null,
    created_at timestamp with time zone default now(),
    updated_at timestamp with time zone default now()
);

alter table comments enable row level security;

create policy "Enable read access for all users"
on comments
for select
using (true);

create policy "Enable insert access for all users"
on comments
for insert
with check (
    true
);

create policy "Enable update access for all users"
on comments
for update
using (
    auth.uid() = author_id
);

create policy "Enable delete access for all users"
on comments
for delete
using (
    auth.uid() = author_id
);


create table tags (
    id uuid primary key default gen_random_uuid(),
    name text unique not null
);

alter table tags enable row level security;

create policy "Enable read access for all users"
on tags
for select
using (true);

create policy "Enable insert access for all users"
on tags
for insert
with check (
    true
);


create table post_tags (
    post_id uuid references posts(id) on delete cascade,
    tag_id uuid references tags(id) on delete cascade,
    primary key (post_id, tag_id)
);

alter table post_tags enable row level security;

create policy "Enable read access for all users"
on post_tags
for select
using (true);

create policy "Enable insert access for all users"
on post_tags
for insert
with check (
    true
);

create policy "Enable delete access for all users"
on post_tags
for delete
using (
    exists (
        select 1
        from posts
        where id = post_id
        and author_id = auth.uid()
    )
);
