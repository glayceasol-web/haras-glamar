-- Torna administrador o usuário com o e-mail abaixo.
-- Troque SEU_EMAIL_AQUI pelo e-mail que você usa para entrar no site e clique em Run.
insert into public.perfis (user_id, email, perfil)
select id, email, 'admin' from auth.users where email = 'SEU_EMAIL_AQUI'
on conflict (user_id) do update set perfil = 'admin';

select email, perfil from public.perfis;
