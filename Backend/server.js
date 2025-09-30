const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '', 
    database: 'colombia'
});


db.connect((err) => {
    if (err) {
        console.error('Error conectando a la base de datos:', err);
        return;
    }
    console.log(' Conectado a la base de datos MySQL');
});

// ========== RUTAS DEPARTAMENTOS ==========

app.get('/api/departamentos', (req, res) => {
    const query = 'SELECT * FROM departamentos ORDER BY nombre';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Error al obtener departamentos:', err);
            return res.status(500).json({ error: err.message });
        }
        res.json(results);
    });
});

app.get('/api/departamentos/:id', (req, res) => {
    const query = 'SELECT * FROM departamentos WHERE id_departamento = ?';
    db.query(query, [req.params.id], (err, results) => {
        if (err) {
            console.error('Error al obtener departamento:', err);
            return res.status(500).json({ error: err.message });
        }
        if (results.length === 0) {
            return res.status(404).json({ error: 'Departamento no encontrado' });
        }
        res.json(results[0]);
    });
});

app.post('/api/departamentos', (req, res) => {
    const { nombre } = req.body;
    
    if (!nombre) {
        return res.status(400).json({ error: 'El nombre es requerido' });
    }
    
    const query = 'INSERT INTO departamentos (nombre) VALUES (?)';
    db.query(query, [nombre], (err, result) => {
        if (err) {
            console.error('Error al crear departamento:', err);
            return res.status(500).json({ error: err.message });
        }
        res.status(201).json({
            id_departamento: result.insertId,
            nombre: nombre,
            message: 'Departamento creado exitosamente'
        });
    });
});

app.put('/api/departamentos/:id', (req, res) => {
    const { nombre } = req.body;
    
    if (!nombre) {
        return res.status(400).json({ error: 'El nombre es requerido' });
    }
    
    const query = 'UPDATE departamentos SET nombre = ? WHERE id_departamento = ?';
    db.query(query, [nombre, req.params.id], (err, result) => {
        if (err) {
            console.error('Error al actualizar departamento:', err);
            return res.status(500).json({ error: err.message });
        }
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Departamento no encontrado' });
        }
        res.json({ 
            id_departamento: parseInt(req.params.id),
            nombre: nombre,
            message: 'Departamento actualizado exitosamente' 
        });
    });
});

app.delete('/api/departamentos/:id', (req, res) => {
    const checkQuery = 'SELECT COUNT(*) as count FROM ciudades WHERE id_departamento = ?';
    db.query(checkQuery, [req.params.id], (err, results) => {
        if (err) {
            console.error('Error al verificar ciudades:', err);
            return res.status(500).json({ error: err.message });
        }
        
        if (results[0].count > 0) {
            return res.status(400).json({ 
                error: 'No se puede eliminar el departamento porque tiene ciudades asociadas' 
            });
        }
        
        const deleteQuery = 'DELETE FROM departamentos WHERE id_departamento = ?';
        db.query(deleteQuery, [req.params.id], (err, result) => {
            if (err) {
                console.error('Error al eliminar departamento:', err);
                return res.status(500).json({ error: err.message });
            }
            if (result.affectedRows === 0) {
                return res.status(404).json({ error: 'Departamento no encontrado' });
            }
            res.json({ message: 'Departamento eliminado exitosamente' });
        });
    });
});


app.get('/api/departamentos/buscar/:nombre', (req, res) => {
    const nombreBusqueda = `%${req.params.nombre}%`; 
    
    const query = 'SELECT * FROM departamentos WHERE nombre LIKE ? ORDER BY nombre';
    db.query(query, [nombreBusqueda], (err, results) => {
        if (err) {
            console.error('Error al buscar departamentos:', err);
            return res.status(500).json({ error: err.message });
        }
        res.json(results);
    });
});

// ========== RUTAS CIUDADES ==========

app.get('/api/ciudades', (req, res) => {
    const query = `
        SELECT 
            c.id_ciudad, 
            c.nombre, 
            c.id_departamento, 
            d.nombre as nombre_departamento
        FROM ciudades c
        LEFT JOIN departamentos d ON c.id_departamento = d.id_departamento
        ORDER BY c.nombre
    `;
    db.query(query, (err, results) => {
        if (err) {
            console.error('Error al obtener ciudades:', err);
            return res.status(500).json({ error: err.message });
        }
        res.json(results);
    });
});

app.get('/api/ciudades/departamento/:id', (req, res) => {
    const query = `
        SELECT 
            c.id_ciudad, 
            c.nombre, 
            c.id_departamento, 
            d.nombre as nombre_departamento
        FROM ciudades c
        LEFT JOIN departamentos d ON c.id_departamento = d.id_departamento
        WHERE c.id_departamento = ?
        ORDER BY c.nombre
    `;
    db.query(query, [req.params.id], (err, results) => {
        if (err) {
            console.error('Error al obtener ciudades por departamento:', err);
            return res.status(500).json({ error: err.message });
        }
        res.json(results);
    });
});

app.get('/api/ciudades/:id', (req, res) => {
    const query = `
        SELECT 
            c.id_ciudad, 
            c.nombre, 
            c.id_departamento, 
            d.nombre as nombre_departamento
        FROM ciudades c
        LEFT JOIN departamentos d ON c.id_departamento = d.id_departamento
        WHERE c.id_ciudad = ?
    `;
    db.query(query, [req.params.id], (err, results) => {
        if (err) {
            console.error('Error al obtener ciudad:', err);
            return res.status(500).json({ error: err.message });
        }
        if (results.length === 0) {
            return res.status(404).json({ error: 'Ciudad no encontrada' });
        }
        res.json(results[0]);
    });
});

app.post('/api/ciudades', (req, res) => {
    const { nombre, id_departamento } = req.body;
    
    if (!nombre) {
        return res.status(400).json({ error: 'El nombre es requerido' });
    }
    
    const query = 'INSERT INTO ciudades (nombre, id_departamento) VALUES (?, ?)';
    db.query(query, [nombre, id_departamento || null], (err, result) => {
        if (err) {
            console.error('Error al crear ciudad:', err);
            return res.status(500).json({ error: err.message });
        }
        res.status(201).json({
            id_ciudad: result.insertId,
            nombre: nombre,
            id_departamento: id_departamento || null,
            message: 'Ciudad creada exitosamente'
        });
    });
});

app.put('/api/ciudades/:id', (req, res) => {
    const { nombre, id_departamento } = req.body;
    
    if (!nombre) {
        return res.status(400).json({ error: 'El nombre es requerido' });
    }
    
    const query = 'UPDATE ciudades SET nombre = ?, id_departamento = ? WHERE id_ciudad = ?';
    db.query(query, [nombre, id_departamento || null, req.params.id], (err, result) => {
        if (err) {
            console.error('Error al actualizar ciudad:', err);
            return res.status(500).json({ error: err.message });
        }
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Ciudad no encontrada' });
        }
        res.json({ 
            id_ciudad: parseInt(req.params.id),
            nombre: nombre,
            id_departamento: id_departamento || null,
            message: 'Ciudad actualizada exitosamente' 
        });
    });
});

app.delete('/api/ciudades/:id', (req, res) => {
    const query = 'DELETE FROM ciudades WHERE id_ciudad = ?';
    db.query(query, [req.params.id], (err, result) => {
        if (err) {
            console.error('Error al eliminar ciudad:', err);
            return res.status(500).json({ error: err.message });
        }
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Ciudad no encontrada' });
        }
        res.json({ message: 'Ciudad eliminada exitosamente' });
    });
});

app.get('/api/ciudades/buscar/:nombre', (req, res) => {
    const nombreBusqueda = `%${req.params.nombre}%`; // para búsqueda parcial
    
    const query = `
        SELECT 
            c.id_ciudad, 
            c.nombre, 
            c.id_departamento, 
            d.nombre as nombre_departamento
        FROM ciudades c
        LEFT JOIN departamentos d ON c.id_departamento = d.id_departamento
        WHERE c.nombre LIKE ?
        ORDER BY c.nombre
    `;
    db.query(query, [nombreBusqueda], (err, results) => {
        if (err) {
            console.error('Error al buscar ciudades:', err);
            return res.status(500).json({ error: err.message });
        }
        res.json(results);
    });
});

// ========== RUTA DE PRUEBA ==========

app.get('/', (req, res) => {
    res.json({ 
        message: 'API Colombia funcionando correctamente',
        endpoints: {
            departamentos: '/api/departamentos',
            ciudades: '/api/ciudades'
        }
    });
});

// ========== INICIAR SERVIDOR ==========

app.listen(PORT, () => {
    console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
    console.log(`📚 API Documentación:`);
    console.log(`   - GET    /api/departamentos`);
    console.log(`   - GET    /api/departamentos/:id`);
    console.log(`   - POST   /api/departamentos`);
    console.log(`   - PUT    /api/departamentos/:id`);
    console.log(`   - DELETE /api/departamentos/:id`);
    console.log(`   - GET    /api/departamentos/buscar/:nombre`);
    console.log(`   - GET    /api/ciudades`);
    console.log(`   - GET    /api/ciudades/:id`);
    console.log(`   - GET    /api/ciudades/departamento/:id`);
    console.log(`   - POST   /api/ciudades`);
    console.log(`   - PUT    /api/ciudades/:id`);
    console.log(`   - DELETE /api/ciudades/:id`);
    console.log(`   - GET    /api/ciudades/buscar/:nombre`);
});