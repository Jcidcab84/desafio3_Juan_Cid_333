CREATE TABLE Usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rol VARCHAR(20) NOT NULL
);


CREATE TABLE Posts (
    id SERIAL PRIMARY KEY,
    título VARCHAR(255) NOT NULL,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    destacado BOOLEAN NOT NULL,
    usuario_id BIGINT,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id)
);


CREATE TABLE Comentarios (
    id SERIAL PRIMARY KEY,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_id BIGINT,
    post_id BIGINT,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id),
    FOREIGN KEY (post_id) REFERENCES Posts(id)
);


INSERT INTO Usuarios (email, nombre, apellido, rol) VALUES ('usuario1@example.com', 'Juan', 'Pérez', 'usuario');
INSERT INTO Usuarios (email, nombre, apellido, rol) VALUES ('usuario2@example.com', 'María', 'González', 'usuario');
INSERT INTO Usuarios (email, nombre, apellido, rol) VALUES ('usuario3@example.com', 'Carlos', 'López', 'usuario');
INSERT INTO Usuarios (email, nombre, apellido, rol) VALUES ('admin@example.com', 'Ana', 'Martínez', 'administrador');
INSERT INTO Usuarios (email, nombre, apellido, rol) VALUES ('usuario4@example.com', 'Laura', 'Sánchez', 'usuario');


INSERT INTO Posts (título, contenido, destacado, usuario_id) VALUES ('Título del post 1', 'Contenido del post 1', false, 4);
INSERT INTO Posts (título, contenido, destacado, usuario_id) VALUES ('Título del post 2', 'Contenido del post 2', true, 4);
INSERT INTO Posts (título, contenido, destacado, usuario_id) VALUES ('Título del post 3', 'Contenido del post 3', true, 1);
INSERT INTO Posts (título, contenido, destacado, usuario_id) VALUES ('Título del post 4', 'Contenido del post 4', false, 1);
INSERT INTO Posts (título, contenido, destacado) VALUES ('Título del post 5', 'Contenido del post 5', false);



INSERT INTO Comentarios (contenido, usuario_id, post_id) VALUES ('Comentario 1 para el post 1', 1, 1);
INSERT INTO Comentarios (contenido, usuario_id, post_id) VALUES ('Comentario 2 para el post 1', 2, 1);
INSERT INTO Comentarios (contenido, usuario_id, post_id) VALUES ('Comentario 3 para el post 1', 3, 1);
INSERT INTO Comentarios (contenido, usuario_id, post_id) VALUES ('Comentario 4 para el post 2', 1, 2);
INSERT INTO Comentarios (contenido, usuario_id, post_id) VALUES ('Comentario 5 para el post 2', 2, 2);


-- Cruza los datos de la tabla usuarios y posts, mostrando las siguientes columnas: nombre y email del usuario junto al título y contenido del post. 
SELECT u.nombre, u.email, p.título, p.contenido
FROM Usuarios u
JOIN Posts p ON u.id = p.usuario_id;

-- Muestra el id, título y contenido de los posts de los administradores
SELECT p.id, p.título, p.contenido
FROM Posts p
JOIN Usuarios u ON p.usuario_id = u.id
WHERE u.rol = 'administrador';

-- Cuenta la cantidad de posts de cada usuario.
SELECT u.id, u.email, COUNT(p.id) AS cantidad_posts
FROM Usuarios u
LEFT JOIN Posts p ON u.id = p.usuario_id
GROUP BY u.id, u.email

-- Muestra el email del usuario que ha creado más posts.
SELECT u.email
FROM Usuarios u
JOIN (
    SELECT usuario_id, COUNT(*) AS cantidad_posts
    FROM Posts
    GROUP BY usuario_id
    ORDER BY cantidad_posts DESC
    LIMIT 1
) AS subquery ON u.id = subquery.usuario_id;

-- Muestra la fecha del último post de cada usuario.
SELECT u.id, u.email, MAX(p.fecha_creacion) AS fecha_ultimo_post
FROM Usuarios u
LEFT JOIN Posts p ON u.id = p.usuario_id
GROUP BY u.id, u.email;

-- Muestra el título y contenido del post (artículo) con más comentarios.
SELECT p.título, p.contenido
FROM Posts p
JOIN (
    SELECT post_id, COUNT(*) AS cantidad_comentarios
    FROM Comentarios
    GROUP BY post_id
    ORDER BY cantidad_comentarios DESC
    LIMIT 1
) AS subquery ON p.id = subquery.post_id;

-- Muestra en una tabla el título de cada post, el contenido de cada post y el contenido

SELECT 
    p.título AS título_post,
    p.contenido AS contenido_post,
    c.contenido AS contenido_comentario,
    u.email AS email_usuario
FROM 
    Posts p
JOIN 
    Comentarios c ON p.id = c.post_id
JOIN 
    Usuarios u ON c.usuario_id = u.id;


-- Muestra el contenido del último comentario de cada usuario.

SELECT 
    u.email AS email_usuario,
    c.contenido AS contenido_ultimo_comentario
FROM 
    Usuarios u
JOIN 
    (
        SELECT 
            usuario_id,
            MAX(fecha_creacion) AS fecha_ultimo_comentario
        FROM 
            Comentarios
        GROUP BY 
            usuario_id
    ) AS ultimos_comentarios ON u.id = ultimos_comentarios.usuario_id
JOIN 
    Comentarios c ON ultimos_comentarios.usuario_id = c.usuario_id 
                  AND ultimos_comentarios.fecha_ultimo_comentario = c.fecha_creacion;


-- Muestra los emails de los usuarios que no han escrito ningún comentario.
SELECT email
FROM Usuarios
WHERE id NOT IN (SELECT DISTINCT usuario_id FROM Comentarios);
