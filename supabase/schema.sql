-- MenuZine shared demo POS schema
-- DEMO ONLY: intentionally allows anonymous customers and demo staff devices to
-- create/read/update demo orders. Do not store personal/customer payment data here.
-- Before production, replace these policies with authenticated role-based policies.

create table if not exists public.menuzine_demo_orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  table_number text not null check (table_number in (
    'Table 1','Table 2','Table 3','Table 4','Table 5','Table 6','Table 7','Table 8','Table 9','Table 10',
    'Table 11','Table 12','Table 13','Table 14','Table 15','Table 16','Table 17','Table 18','Table 19','Table 20'
  )),
  payment_method text not null default 'Cash' check (payment_method = 'Cash'),
  total numeric(12,2) not null check (total >= 0),
  items jsonb not null default '[]'::jsonb,
  status text not null default 'New' check (status in ('New','Preparing','Ready','Completed')),
  paid boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.menuzine_demo_orders enable row level security;
grant select, insert, update on public.menuzine_demo_orders to anon, authenticated;

drop policy if exists "demo orders can be created publicly" on public.menuzine_demo_orders;
create policy "demo orders can be created publicly"
on public.menuzine_demo_orders for insert to anon, authenticated
with check (payment_method = 'Cash' and total >= 0);

drop policy if exists "demo orders can be viewed publicly" on public.menuzine_demo_orders;
create policy "demo orders can be viewed publicly"
on public.menuzine_demo_orders for select to anon, authenticated
using (true);

drop policy if exists "demo orders can be updated publicly" on public.menuzine_demo_orders;
create policy "demo orders can be updated publicly"
on public.menuzine_demo_orders for update to anon, authenticated
using (true)
with check (payment_method = 'Cash');

do $$
begin
  alter publication supabase_realtime add table public.menuzine_demo_orders;
exception when duplicate_object then null;
end $$;
