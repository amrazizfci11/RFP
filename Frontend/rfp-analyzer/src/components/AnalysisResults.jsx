import React from 'react'

function AnalysisResults({ document }) {
  if (!document.analysisResult) {
    return (
      <div className="analysis-results">
        <h2>{document.fileName}</h2>
        <div className="analyzing-message">
          <div className="spinner"></div>
          <p>Analysis in progress...</p>
          <p className="hint">This may take a few moments. The page will update automatically.</p>
        </div>
      </div>
    )
  }

  const { analysisResult } = document

  const formatDate = (dateString) => {
    const date = new Date(dateString)
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString()
  }

  const renderField = (label, value) => {
    if (!value || value === 'Not specified in document') {
      return (
        <div className="analysis-field">
          <h3>{label}</h3>
          <p className="not-found">Not specified in document</p>
        </div>
      )
    }

    return (
      <div className="analysis-field">
        <h3>{label}</h3>
        <div className="field-content">{value}</div>
      </div>
    )
  }

  return (
    <div className="analysis-results">
      <div className="results-header">
        <h2>{document.fileName}</h2>
        <p className="analysis-date">Analyzed: {formatDate(analysisResult.analyzedAt)}</p>
      </div>

      <div className="results-grid">
        {renderField('Project Name', analysisResult.projectName)}
        {renderField('Project Duration', analysisResult.projectDuration)}
        {renderField('Human Resources Hierarchy', analysisResult.humanResourcesHierarchy)}
        {renderField('Project Stages', analysisResult.projectStages)}
        {renderField('Special Conditions', analysisResult.specialConditions)}
        {renderField('Implementation Boundaries', analysisResult.implementationBoundaries)}
      </div>

      <div className="raw-analysis">
        <h3>Full Analysis</h3>
        <div className="raw-analysis-content">
          <pre>{analysisResult.rawAnalysis}</pre>
        </div>
      </div>
    </div>
  )
}

export default AnalysisResults
