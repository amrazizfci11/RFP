import React, { useState, useEffect } from 'react'
import { useAuth } from '../contexts/AuthContext'
import FileUpload from '../components/FileUpload'
import DocumentList from '../components/DocumentList'
import AnalysisResults from '../components/AnalysisResults'
import api from '../services/api'
import '../styles/Dashboard.css'

function Dashboard() {
  const { user, logout } = useAuth()
  const [documents, setDocuments] = useState([])
  const [selectedDocument, setSelectedDocument] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    loadDocuments()
  }, [])

  const loadDocuments = async () => {
    try {
      setLoading(true)
      const response = await api.get('/api/documents')
      setDocuments(response.data)
      setError('')
    } catch (err) {
      setError('Failed to load documents')
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  const handleUploadSuccess = () => {
    loadDocuments()
  }

  const handleSelectDocument = async (documentId) => {
    try {
      const response = await api.get(`/api/documents/${documentId}`)
      setSelectedDocument(response.data)
    } catch (err) {
      setError('Failed to load document details')
      console.error(err)
    }
  }

  const handleDeleteDocument = async (documentId) => {
    if (!window.confirm('Are you sure you want to delete this document?')) {
      return
    }

    try {
      await api.delete(`/api/documents/${documentId}`)
      setDocuments(documents.filter((doc) => doc.id !== documentId))
      if (selectedDocument?.id === documentId) {
        setSelectedDocument(null)
      }
    } catch (err) {
      setError('Failed to delete document')
      console.error(err)
    }
  }

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <div className="header-content">
          <h1>RFP Analyzer</h1>
          <div className="user-info">
            <span>{user?.email}</span>
            <button onClick={logout} className="btn btn-secondary">
              Logout
            </button>
          </div>
        </div>
      </header>

      <main className="dashboard-content">
        {error && <div className="error-message">{error}</div>}

        <div className="dashboard-grid">
          <div className="sidebar">
            <FileUpload
              onUploadSuccess={handleUploadSuccess}
              documentCount={documents.length}
            />
            <DocumentList
              documents={documents}
              selectedDocument={selectedDocument}
              onSelectDocument={handleSelectDocument}
              onDeleteDocument={handleDeleteDocument}
              loading={loading}
            />
          </div>

          <div className="main-content">
            {selectedDocument ? (
              <AnalysisResults document={selectedDocument} />
            ) : (
              <div className="empty-state">
                <h2>Welcome to RFP Analyzer</h2>
                <p>Upload RFP documents (PDF or Word) to get AI-powered analysis</p>
                <ul>
                  <li>Upload up to 10 documents</li>
                  <li>Automatic analysis using Claude AI</li>
                  <li>Extract key project information</li>
                  <li>View project details, resources, and stages</li>
                </ul>
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  )
}

export default Dashboard
