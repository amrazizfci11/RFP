import React from 'react'

function DocumentList({ documents, selectedDocument, onSelectDocument, onDeleteDocument, loading }) {
  const formatFileSize = (bytes) => {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
  }

  const formatDate = (dateString) => {
    const date = new Date(dateString)
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString()
  }

  if (loading) {
    return (
      <div className="document-list-card">
        <h3>Your Documents</h3>
        <p className="loading">Loading documents...</p>
      </div>
    )
  }

  if (documents.length === 0) {
    return (
      <div className="document-list-card">
        <h3>Your Documents</h3>
        <p className="empty-documents">No documents uploaded yet</p>
      </div>
    )
  }

  return (
    <div className="document-list-card">
      <h3>Your Documents</h3>
      <div className="document-list">
        {documents.map((doc) => (
          <div
            key={doc.id}
            className={`document-item ${
              selectedDocument?.id === doc.id ? 'selected' : ''
            }`}
            onClick={() => onSelectDocument(doc.id)}
          >
            <div className="document-info">
              <h4>{doc.fileName}</h4>
              <div className="document-meta">
                <span>{formatFileSize(doc.fileSize)}</span>
                <span>{doc.fileType}</span>
              </div>
              <p className="document-date">{formatDate(doc.uploadedAt)}</p>
              {doc.analysisResult ? (
                <span className="analysis-status analyzed">Analyzed</span>
              ) : (
                <span className="analysis-status analyzing">Analyzing...</span>
              )}
            </div>
            <button
              className="btn-delete"
              onClick={(e) => {
                e.stopPropagation()
                onDeleteDocument(doc.id)
              }}
              title="Delete document"
            >
              ×
            </button>
          </div>
        ))}
      </div>
    </div>
  )
}

export default DocumentList
