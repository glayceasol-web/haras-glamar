-- Haras GLAMAR · configuração do banco (rode uma vez no SQL Editor do Supabase)

-- 1. Perfis de acesso
create table if not exists public.perfis (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text,
  nome text,
  perfil text not null default 'usuario' check (perfil in ('admin','financeiro','usuario','leitura')),
  criado timestamptz not null default now()
);

-- O primeiro usuário criado vira administrador; os demais entram como "usuario"
create or replace function public.novo_usuario() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.perfis(user_id, email, perfil)
  values (new.id, new.email, case when exists (select 1 from public.perfis) then 'usuario' else 'admin' end)
  on conflict (user_id) do nothing;
  return new;
end $$;
drop trigger if exists ao_criar_usuario on auth.users;
create trigger ao_criar_usuario after insert on auth.users
  for each row execute function public.novo_usuario();

-- Cria perfil para quem já existia antes deste script
insert into public.perfis(user_id, email, perfil)
select u.id, u.email, case when row_number() over (order by u.created_at) = 1 and not exists (select 1 from public.perfis) then 'admin' else 'usuario' end
from auth.users u on conflict (user_id) do nothing;

create or replace function public.meu_perfil() returns text
language sql stable security definer set search_path = public as $$
  select perfil from public.perfis where user_id = auth.uid()
$$;

alter table public.perfis enable row level security;
drop policy if exists "ver perfis" on public.perfis;
create policy "ver perfis" on public.perfis for select to authenticated
  using (user_id = auth.uid() or public.meu_perfil() = 'admin');
drop policy if exists "admin altera perfis" on public.perfis;
create policy "admin altera perfis" on public.perfis for update to authenticated
  using (public.meu_perfil() = 'admin') with check (public.meu_perfil() = 'admin');

-- 2. Dados do sistema (cada registro guarda um item de uma aba)
create table if not exists public.registros (
  colecao text not null,
  id text not null,
  dados jsonb not null default '{}'::jsonb,
  atualizado timestamptz not null default now(),
  atualizado_por uuid default auth.uid(),
  primary key (colecao, id)
);

create or replace function public.pode_ler(c text) returns boolean
language sql stable as $$
  select auth.uid() is not null and (
    c not in ('lancamentos','competicoes') or public.meu_perfil() in ('admin','financeiro'))
$$;
create or replace function public.pode_gravar(c text) returns boolean
language sql stable as $$
  select case
    when public.meu_perfil() is null or public.meu_perfil() = 'leitura' then false
    when c = 'config' then public.meu_perfil() = 'admin'
    when c in ('lancamentos','competicoes') then public.meu_perfil() in ('admin','financeiro')
    else true end
$$;

create or replace function public.marca_atualizacao() returns trigger language plpgsql as $$
begin new.atualizado = now(); new.atualizado_por = auth.uid(); return new; end $$;
drop trigger if exists registros_atualizado on public.registros;
create trigger registros_atualizado before insert or update on public.registros
  for each row execute function public.marca_atualizacao();

alter table public.registros enable row level security;
drop policy if exists "ler registros" on public.registros;
create policy "ler registros" on public.registros for select to authenticated using (public.pode_ler(colecao));
drop policy if exists "incluir registros" on public.registros;
create policy "incluir registros" on public.registros for insert to authenticated with check (public.pode_gravar(colecao));
drop policy if exists "alterar registros" on public.registros;
create policy "alterar registros" on public.registros for update to authenticated using (public.pode_gravar(colecao)) with check (public.pode_gravar(colecao));
drop policy if exists "apagar registros" on public.registros;
create policy "apagar registros" on public.registros for delete to authenticated using (public.pode_gravar(colecao));

-- 3. Atualização ao vivo entre os computadores da equipe
do $$ begin
  alter publication supabase_realtime add table public.registros;
exception when duplicate_object then null; end $$;
