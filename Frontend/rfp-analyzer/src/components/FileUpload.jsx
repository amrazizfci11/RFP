import React, { useState } from 'react'
import api from '../services/api'

function FileUpload({ onUploadSuccess, documentCount }) {
  const [selectedFile, setSelectedFile] = useState(null)
  const [uploading, setUploading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  const handleFileChange = (e) => {
    const file = e.target.files[0]
    if (file) {
      const allowedTypes = [
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      ]

      if (!allowedTypes.includes(file.type)) {
        setError('Only PDF and Word documents are allowed')
        setSelectedFile(null)
        return
      }

      if (file.size > 50 * 1024 * 1024) {
        setError('File size must not exceed 50MB')
        setSelectedFile(null)
        return
      }

      setSelectedFile(file)
      setError('')
      setSuccess('')
    }
  }

  const handleUpload = async () => {
    if (!selectedFile) {
      setError('Please select a file')
      return
    }

    if (documentCount >= 10) {
      setError('You have reached the maximum limit of 10 documents')
      return
    }

    const formData = new FormData()
    formData.append('file', selectedFile)

    setUploading(true)
    setError('')
    setSuccess('')

    try {
      await api.post('/api/documents/upload', formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      })

      setSuccess('Document uploaded successfully! Analysis in progress...')
      setSelectedFile(null)

      // Reset file input
      const fileInput = document.getElementById('file-input')
      if (fileInput) fileInput.value = ''

      // Notify parent component
      onUploadSuccess()
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to upload document')
    } finally {
      setUploading(false)
    }
  }

  return (
    <div className="file-upload-card">
      <h3>Upload Document</h3>
      <p className="upload-info">
        {documentCount}/10 documents uploaded
      </p>

      {error && <div className="error-message">{error}</div>}
      {success && <div className="success-message">{success}</div>}

      <div className="file-input-wrapper">
        <input
          type="file"
          id="file-input"
          accept=".pdf,.doc,.docx"
          onChange={handleFileChange}
          disabled={uploading || documentCount >= 10}
        />
        {selectedFile && (
          <p className="selected-file">
            Selected: {selectedFile.name}
          </p>
        )}
      </div>

      <button
        onClick={handleUpload}
        disabled={!selectedFile || uploading || documentCount >= 10}
        className="btn btn-primary"
      >
        {uploading ? 'Uploading...' : 'Upload & Analyze'}
      </button>

      <div className="upload-hint">
        <small>Supported formats: PDF, DOC, DOCX (max 50MB)</small>
      </div>
    </div>
  )
}

export default FileUpload
