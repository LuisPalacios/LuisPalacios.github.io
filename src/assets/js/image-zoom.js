// Sistema de zoom automático para imágenes en image-box
document.addEventListener('DOMContentLoaded', function() {
    // Solo aplicar a imágenes dentro de .image-box
    const imageBoxes = document.querySelectorAll('.image-box img');

    imageBoxes.forEach(function(img) {
        img.addEventListener('click', function(e) {
            e.preventDefault();
            openImageModal(this);
        });
    });

    function openImageModal(img) {
        // Crear el modal
        const modal = document.createElement('div');
        modal.className = 'image-modal';

        // Crear botón de cerrar
        const closeBtn = document.createElement('button');
        closeBtn.className = 'image-modal-close';
        closeBtn.innerHTML = '&times;';
        closeBtn.setAttribute('aria-label', 'Cerrar');

        // Crear imagen ampliada
        const modalImg = document.createElement('img');
        modalImg.src = img.src;
        modalImg.alt = img.alt;

        // Agregar elementos al modal
        modal.appendChild(closeBtn);
        modal.appendChild(modalImg);

        // Agregar modal al body
        document.body.appendChild(modal);

        // Desactivar scroll del body
        document.body.classList.add('modal-open');

        // Mostrar modal con animación
        setTimeout(() => {
            modal.classList.add('show');
        }, 10);

        // Cerrar modal al hacer click en el fondo
        modal.addEventListener('click', function(e) {
            if (e.target === modal || e.target === closeBtn) {
                closeModal();
            }
        });

        // Cerrar modal con tecla Escape
        function handleEscapeKey(e) {
            if (e.key === 'Escape') {
                closeModal();
            }
        }

        document.addEventListener('keydown', handleEscapeKey);

                function closeModal() {
            modal.classList.remove('show');

            // Reactivar scroll del body
            document.body.classList.remove('modal-open');

            // Remover event listener de tecla Escape
            document.removeEventListener('keydown', handleEscapeKey);

            setTimeout(() => {
                if (modal.parentNode) {
                    modal.parentNode.removeChild(modal);
                }
            }, 300);
        }
    }
});