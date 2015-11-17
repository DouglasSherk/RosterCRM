var Lead = React.createClass({
  getInitialState: function() {
    return JSON.parse(this.props.presenter);
  },

  render: function() {
    return (
      <div>
        <h4>{ this.state.name }</h4>
      </div>
    )
  }
});
