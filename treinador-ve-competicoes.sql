-- Libera a leitura das Competições para todos os perfis logados (o app esconde os valores para o Treinador).
-- Entradas e saídas e Compras parceladas continuam só para Administrador e Financeiro.
create or replace function public.pode_ler(c text) returns boolean
language sql stable as $$
  select auth.uid() is not null and (
    c not in ('lancamentos','compras') or public.meu_perfil() in ('admin','financeiro'))
$$;
