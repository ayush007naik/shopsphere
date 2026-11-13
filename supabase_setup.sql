-- ===========================================================================
-- ShopSphere — Supabase schema, security policies and sample catalogue
-- ===========================================================================
--
-- Run this entire script once in the Supabase SQL Editor (Dashboard → SQL).
-- It is safe to re-run: tables, functions and policies are created idempotently
-- and the sample rows are upserted by their fixed IDs.
--
-- The sample IDs match lib/core/services/demo_data.dart, so switching between
-- the offline demo and a live project gives the app the same catalogue.
--
-- Security model
--   * categories + products: publicly readable, writable only by the dashboard
--     or a service-role key (never shipped in the app).
--   * profiles: each signed-in user can read, insert and update only their own
--     row. Rows are created automatically when a user signs up.
--
-- After running this script:
--   1. Authentication → Providers → Email: enable Email sign-ups.
--   2. Optionally disable "Confirm email" for faster classroom demos.
--   3. Copy the Project URL and the publishable/anon key into --dart-define.
-- ===========================================================================

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table if not exists public.categories (
  id         uuid primary key default gen_random_uuid(),
  name       text not null check (char_length(trim(name)) > 0),
  slug       text not null unique check (char_length(trim(slug)) > 0),
  icon       text not null default 'category',
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id          uuid primary key default gen_random_uuid(),
  name        text not null check (char_length(trim(name)) > 0),
  description text not null default '',
  price       numeric(10, 2) not null default 0 check (price >= 0),
  image_url   text not null default '',
  category_id uuid references public.categories (id) on delete set null,
  rating      numeric(2, 1) not null default 0 check (rating >= 0 and rating <= 5),
  stock       integer not null default 0 check (stock >= 0),
  is_featured boolean not null default false,
  created_at  timestamptz not null default now()
);

create index if not exists products_category_id_idx on public.products (category_id);
create index if not exists products_featured_idx on public.products (is_featured);
create index if not exists products_created_at_idx on public.products (created_at desc);

create table if not exists public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  full_name  text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Profile provisioning
-- ---------------------------------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (
    new.id,
    coalesce(
      nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
      split_part(coalesce(new.email, ''), '@', 1)
    )
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

-- Backfill profiles for accounts that already existed before this script ran.
insert into public.profiles (id, full_name)
select
  u.id,
  coalesce(
    nullif(trim(u.raw_user_meta_data ->> 'full_name'), ''),
    split_part(coalesce(u.email, ''), '@', 1)
  )
from auth.users u
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.profiles enable row level security;

drop policy if exists "Catalogue is publicly readable" on public.categories;
create policy "Catalogue is publicly readable"
on public.categories for select
to anon, authenticated
using (true);

drop policy if exists "Products are publicly readable" on public.products;
create policy "Products are publicly readable"
on public.products for select
to anon, authenticated
using (true);

drop policy if exists "Users can view their own profile" on public.profiles;
create policy "Users can view their own profile"
on public.profiles for select
to authenticated
using (auth.uid() = id);

drop policy if exists "Users can insert their own profile" on public.profiles;
create policy "Users can insert their own profile"
on public.profiles for insert
to authenticated
with check (auth.uid() = id);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
on public.profiles for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

-- No insert/update/delete policies exist for the catalogue. Only the
-- service-role key (which bypasses RLS) can modify it, so credentials for the
-- app can never alter products or categories.

-- ---------------------------------------------------------------------------
-- Privileges
-- ---------------------------------------------------------------------------

grant usage on schema public to anon, authenticated;
grant select on public.categories, public.products to anon, authenticated;
grant select, insert, update on public.profiles to authenticated;

-- ---------------------------------------------------------------------------
-- Sample catalogue — categories
-- ---------------------------------------------------------------------------

insert into public.categories (id, name, slug, icon, sort_order)
values
  ('11111111-1111-4111-8111-111111111101', 'Audio',         'audio',       'headphones', 1),
  ('11111111-1111-4111-8111-111111111102', 'Watches',       'watches',     'watch',      2),
  ('11111111-1111-4111-8111-111111111103', 'Bags',          'bags',        'bag',        3),
  ('11111111-1111-4111-8111-111111111104', 'Home & Living', 'home-living', 'home',       4),
  ('11111111-1111-4111-8111-111111111105', 'Footwear',      'footwear',    'footwear',   5),
  ('11111111-1111-4111-8111-111111111106', 'Eyewear',       'eyewear',     'eyewear',    6),
  ('11111111-1111-4111-8111-111111111107', 'Skincare',      'skincare',    'skincare',   7),
  ('11111111-1111-4111-8111-111111111108', 'Tech',          'tech',        'tech',       8)
on conflict (id) do update set
  name       = excluded.name,
  slug       = excluded.slug,
  icon       = excluded.icon,
  sort_order = excluded.sort_order;

-- ---------------------------------------------------------------------------
-- Sample catalogue — products
-- ---------------------------------------------------------------------------

with seed (
  id, name, description, price, image_url, category_id,
  rating, stock, is_featured, minutes_ago
) as (
  values
    (
      '22222222-2222-4222-8222-222222222201'::uuid,
      'Aurora Wireless Headphones',
      'Immersive over-ear headphones with adaptive noise cancelling and a 40-hour battery. Memory-foam cushions keep long listening sessions comfortable, while the fold-flat design travels easily.',
      149.00,
      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111101'::uuid,
      4.8, 24, true, 1
    ),
    (
      '22222222-2222-4222-8222-222222222202'::uuid,
      'Pulse Mini Speaker',
      'A pocket-sized speaker with a surprisingly full sound. Splash resistant, USB-C rechargeable, and ready for twelve hours of play.',
      79.00,
      'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111101'::uuid,
      4.5, 41, false, 2
    ),
    (
      '22222222-2222-4222-8222-222222222203'::uuid,
      'Heritage Leather Watch',
      'A quietly confident timepiece with a brushed stainless case and a vegetable-tanned leather strap. Japanese quartz movement keeps it precise; the slim profile keeps it versatile.',
      219.00,
      'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111102'::uuid,
      4.7, 12, true, 3
    ),
    (
      '22222222-2222-4222-8222-222222222204'::uuid,
      'Meridian Smartwatch',
      'Health tracking, notifications and a bright always-on display in a clean, minimal case. Up to seven days of battery on a single charge.',
      199.00,
      'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111102'::uuid,
      4.6, 18, false, 4
    ),
    (
      '22222222-2222-4222-8222-222222222205'::uuid,
      'Voyager Canvas Backpack',
      'A hard-wearing canvas backpack with a padded laptop sleeve and thoughtful internal pockets. Designed for commutes, weekends and everything in between.',
      89.00,
      'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111103'::uuid,
      4.6, 30, true, 5
    ),
    (
      '22222222-2222-4222-8222-222222222206'::uuid,
      'Atelier Leather Tote',
      'An everyday tote cut from full-grain leather that softens with use. Roomy enough for a 14-inch laptop, finished with hand-stitched handles.',
      129.00,
      'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111103'::uuid,
      4.9, 9, false, 6
    ),
    (
      '22222222-2222-4222-8222-222222222207'::uuid,
      'Halo Ceramic Lamp',
      'A hand-glazed ceramic table lamp that casts a warm, diffused glow. The soft neutral finish sits comfortably in bedrooms, reading nooks and living rooms.',
      69.00,
      'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111104'::uuid,
      4.4, 22, true, 7
    ),
    (
      '22222222-2222-4222-8222-222222222208'::uuid,
      'Solstice Soy Candle',
      'Hand-poured soy wax with notes of cedar, amber and bergamot. Burns cleanly for up to 45 hours in a reusable stoneware vessel.',
      24.00,
      'https://images.unsplash.com/photo-1602874801007-bd458bb1b8b6?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111104'::uuid,
      4.8, 65, false, 8
    ),
    (
      '22222222-2222-4222-8222-222222222209'::uuid,
      'Terra Runner Sneakers',
      'Lightweight everyday runners with a breathable knit upper and a responsive foam midsole. Built for city miles and easy weekends.',
      119.00,
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111105'::uuid,
      4.7, 27, true, 9
    ),
    (
      '22222222-2222-4222-8222-222222222210'::uuid,
      'Court Classic Trainers',
      'A clean leather court shoe that works with denim, tailoring and everything in between. Cushioned insole and a durable rubber sole.',
      99.00,
      'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111105'::uuid,
      4.5, 34, false, 10
    ),
    (
      '22222222-2222-4222-8222-222222222211'::uuid,
      'Horizon Sunglasses',
      'Classic acetate frames with polarised lenses and full UV400 protection. A timeless silhouette with a comfortable keyhole bridge.',
      79.00,
      'https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111106'::uuid,
      4.6, 19, true, 11
    ),
    (
      '22222222-2222-4222-8222-222222222212'::uuid,
      'Studio Round Frames',
      'Fine metal frames with a rounded shape and lightweight feel. Comes with clear lenses ready for your prescription.',
      59.00,
      'https://images.unsplash.com/photo-1572635196237-14b3f281503f?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111106'::uuid,
      4.3, 14, false, 12
    ),
    (
      '22222222-2222-4222-8222-222222222213'::uuid,
      'Botanic Glow Serum',
      'A lightweight vitamin C serum that brightens and evens tone without stickiness. Formulated with botanical antioxidants for daily use.',
      39.00,
      'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111107'::uuid,
      4.8, 52, true, 13
    ),
    (
      '22222222-2222-4222-8222-222222222214'::uuid,
      'Daily Ritual Moisturiser',
      'A ceramide-rich daily moisturiser that strengthens the skin barrier and layers well under sunscreen. Fragrance free and non-greasy.',
      29.00,
      'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111107'::uuid,
      4.7, 70, false, 14
    ),
    (
      '22222222-2222-4222-8222-222222222215'::uuid,
      'Tactile Mechanical Keyboard',
      'A compact 75% mechanical keyboard with hot-swappable switches and a solid aluminium frame. Bluetooth and USB-C connectivity for a tidy desk setup.',
      139.00,
      'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111108'::uuid,
      4.9, 16, true, 15
    ),
    (
      '22222222-2222-4222-8222-222222222216'::uuid,
      'Frame Compact Camera',
      'A pocketable mirrorless camera with a 24MP sensor and a bright prime lens. Film-inspired colour profiles make everyday moments feel considered.',
      349.00,
      'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=900&q=80',
      '11111111-1111-4111-8111-111111111108'::uuid,
      4.7, 7, false, 16
    )
)
insert into public.products (
  id, name, description, price, image_url, category_id,
  rating, stock, is_featured, created_at
)
select
  id, name, description, price, image_url, category_id,
  rating, stock, is_featured, now() - make_interval(mins => minutes_ago)
from seed
on conflict (id) do update set
  name        = excluded.name,
  description = excluded.description,
  price       = excluded.price,
  image_url   = excluded.image_url,
  category_id = excluded.category_id,
  rating      = excluded.rating,
  stock       = excluded.stock,
  is_featured = excluded.is_featured,
  created_at  = excluded.created_at;

-- ===========================================================================
-- Done. Verify with:
--   select count(*) from public.categories;  -- 8
--   select count(*) from public.products;    -- 16
-- ===========================================================================
