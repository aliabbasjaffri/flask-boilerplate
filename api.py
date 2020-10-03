from mongo import MongoAPI
from flask import Flask, Response, request, json, render_template

app = Flask(__name__)


# default sanity tester
@app.route('/hello')
def hello():
    return render_template('hello.html'), 200


@app.route('/')
def base():
    return Response(
        response=json.dumps({
            'Status': 'Up and running!'}),
        status=200,
        mimetype='application/json')


# Update the route to your addressing scheme
@app.route('/<route>', methods=['POST'])
def insert():
    if request.json is None or request.json == {}:
        return Response(
            response=json.dumps({
                'Error': 'Please provide correct/complete information'}),
            status=400,
            mimetype='application/json')

    response = MongoAPI().insert(request.json)

    return Response(
        response=json.dumps(response),
        status=200,
        mimetype='application/json')


@app.route('/<route>', methods=['GET'])
def read():
    response = MongoAPI().read_all_items()

    return Response(
        response=json.dumps(response),
        status=200,
        mimetype='application/json')


@app.route('/<route>/<:id>', methods=['PUT'])
def update(id):
    if request.json is None or request.json == {}:
        return Response(
            response=json.dumps({
                'Error': 'Please provide data to update'}),
            status=400,
            mimetype='application/json')
    elif id < 0:
        return Response(
            response=json.dumps({
                'Error': 'Please provide correct item id'}),
            status=400,
            mimetype='application/json')

    response = MongoAPI().update(request.json, id)

    return Response(
        response=json.dumps(response),
        status=200,
        mimetype='application/json')


@app.route('/<route>/<:id>', methods=['DELETE'])
def delete(id):
    if id < 0:
        return Response(
            response=json.dumps({
                'Error': 'Please provide correct item id'}),
            status=400,
            mimetype='application/json')

    response = MongoAPI().delete(id)

    return Response(
        response=json.dumps(response),
        status=200,
        mimetype='application/json')


@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404


if __name__ == '__main__':
    # Remove port=5000 and debug=True for running
    # the application in production environment
    # app.run(debug=True, port=5000, host='0.0.0.0')
    app.run(host='0.0.0.0')
